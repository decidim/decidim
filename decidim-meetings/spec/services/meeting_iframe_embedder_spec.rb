# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingIframeEmbedder do
      subject { described_class.new(url) }

      let(:request_host) { "decidim.org" }
      let(:services) { %w(www.youtube.com www.twitch.tv meet.jit.si) }

      before do
        allow(Decidim::Meetings).to receive(:embeddable_services).and_return services
      end

      describe "#embed_transformed_url" do
        context "with a valid youtube URL" do
          let(:url) { "https://www.youtube.com/watch?v=aiyHi9MzW30" }

          it "is transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq("https://www.youtube-nocookie.com/embed/aiyHi9MzW30")
          end
        end

        context "with an invalid youtube URL" do
          let(:url) { "https://www.youtube.com/watch/foo/bar" }

          it "isn't transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end

        context "with a valid Twitch URL" do
          let(:url) { "https://www.twitch.tv/videos/920134652?collection=YQZOzRslZRZ0TQ" }

          it "is transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq("https://player.twitch.tv/?video=920134652&parent=decidim.org")
          end
        end

        context "with an invalid Twitch URL" do
          let(:url) { "https://www.twitch.tv/foo/bar" }

          it "isn't transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end

        context "with a not recognized streaming URL" do
          let(:url) { "https://meet.jit.si/decidim-meeting" }

          it "isn't transformed" do
            expect(subject.embed_transformed_url(request_host)).to eq(url)
          end
        end
      end

      describe "#embeddable?" do
        context "with a valid youtube URL" do
          let(:url) { "https://www.youtube.com/watch?v=aiyHi9MzW30" }

          it "is embeddable" do
            expect(subject).to be_embeddable
          end
        end

        context "with a valid Twitch URL" do
          let(:url) { "https://www.twitch.tv/videos/920134652?collection=YQZOzRslZRZ0TQ" }

          it "is embeddable" do
            expect(subject).to be_embeddable
          end
        end

        context "with a not recognized streaming URL" do
          let(:url) { "https://example.org/decidim-meeting" }

          it "is not embeddable" do
            expect(subject).not_to be_embeddable
          end

          context "and emebeddable services are customized" do
            let(:services) { %w(www.youtube.com www.twitch.tv meet.jit.si example.org) }

            it "is not embeddable" do
              expect(subject).to be_embeddable
            end
          end
        end
      end

      describe "#embed_code" do
        let(:url) { "https://www.youtube.com/watch?v=aiyHi9MzW30" }

        it "generates an iframe tag with the embed url" do
          embed_code = subject.embed_code(request_host)

          expect(embed_code).to include(subject.embed_transformed_url(request_host))
          expect(embed_code).to include(%(<div))
          expect(embed_code).to include(%(class="disabled-iframe"))
          expect(embed_code).to include("</div")
        end
      end
    end
  end
end
