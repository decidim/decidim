# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MailerHelper do
    describe "#decidim_transform_image_urls" do
      let(:host) { "example.org" }

      let(:user_input) do
        %{(<p>Hello, %{name}</p>
        <a href="https://meta.decidim.org">Link</a>
        <img src="/rails/active_storage/blobs/redirect/12345.JPG" alt="image" />
        <a href="https://meta.decidim.org/">Link</a>
        <img src="/rails/active_storage/blobs/redirect/56789.JPG" alt="second image" />)}
      end

      context "when decidim_transform_image_urls is invoked" do
        subject { helper.send(:decidim_transform_image_urls, user_input, host) }

        it "transforms image URLs with the host" do
          root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host:).chomp("/")
          expect(subject).to include(%(<img src="#{root_url}/rails/active_storage/blobs/redirect/12345.JPG"))
          expect(subject).to include(%(<img src="#{root_url}/rails/active_storage/blobs/redirect/56789.JPG"))
        end

        context "when a relative src matches the suffix of an absolute URL" do
          let(:user_input) do
            %(<img src="/image.jpg" alt="relative" /><img src="https://example.com/image.jpg" alt="absolute" />)
          end

          it "transforms only the relative URL" do
            root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host:).chomp("/")

            expect(subject).to include(%(<img src="#{root_url}/image.jpg" alt="relative" />))
            expect(subject).to include(%(<img src="https://example.com/image.jpg" alt="absolute" />))
          end
        end

        context "when src uses data/protocol-relative/cid URLs" do
          let(:user_input) do
            %(<img src="data:image/png;base64,AAAA" alt="data" />
<img src="//cdn.example.org/image.jpg" alt="protocol-relative" />
<img src="cid:logo@example.org" alt="cid" />)
          end

          it "keeps them unchanged" do
            expect(subject).to include(%(src="data:image/png;base64,AAAA"))
            expect(subject).to include(%(src="//cdn.example.org/image.jpg"))
            expect(subject).to include(%(src="cid:logo@example.org"))
          end
        end

        context "when src attribute is single-quoted" do
          let(:user_input) { "<img src='/image.jpg' alt='relative' />" }

          it "transforms the URL preserving single quotes" do
            root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host:).chomp("/")
            expect(subject).to include(%(<img src='#{root_url}/image.jpg' alt='relative' />))
          end
        end

        context "when host is not present" do
          subject { helper.send(:decidim_transform_image_urls, user_input, nil) }

          it "returns the full content" do
            expect(subject).to eq user_input
          end
        end

        context "when the CDN host is defined" do
          let(:cdn_host) { "https://cdn.example.org" }

          before do
            allow(Decidim).to receive(:storage_cdn_host).and_return(cdn_host)
          end

          it "transforms image URLs with the CDN host" do
            expect(subject).to include(%(<img src="https://cdn.example.org/rails/active_storage/blobs/redirect/12345.JPG"))
            expect(subject).to include(%(<img src="https://cdn.example.org/rails/active_storage/blobs/redirect/56789.JPG"))
          end
        end
      end
    end
  end
end
