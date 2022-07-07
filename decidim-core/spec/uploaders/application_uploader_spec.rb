# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationUploader do
    subject { described_class.new(model, mounted_as) }

    let(:model) { create(:organization) }
    let(:mounted_as) { :official_img_header }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("PORT", instance_of(Integer)).and_return(local_port) if respond_to?(:local_port)
      allow(ENV).to receive(:fetch).with("HOSTNAME", nil).and_return(hostname) if respond_to?(:hostname)
    end

    describe "#variant_url" do
      shared_context "with force_ssl enabled" do
        before do
          allow(Rails.application.config).to receive(:force_ssl).and_return(true)
        end
      end

      shared_examples "development local storage protocol options" do
        let(:default_port) { Rails.env.development? ? 3000 : Capybara.server_port }

        it "returns a URL containing the port only" do
          expect(subject.variant_url(:testing)).to match(%r{^http://localhost:#{default_port}/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
        end

        context "when force_ssl is enabled" do
          include_context "with force_ssl enabled"

          it "returns a URL containing the port and protocol" do
            expect(subject.variant_url(:testing)).to match(%r{^https://localhost:#{default_port}/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
          end

          context "and the PORT environment variable is defined as 3001" do
            let(:local_port) { 3001 }

            it "returns a URL containing the port and protocol" do
              expect(subject.variant_url(:testing)).to match(%r{^https://localhost:3001/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
            end
          end

          context "and the PORT environment variable is defined as 443" do
            let(:local_port) { 443 }

            it "returns a URL containing the protocol only" do
              expect(subject.variant_url(:testing)).to match(%r{^https://localhost/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
            end
          end
        end

        context "with an existing variant" do
          subject { test_class.new(model, mounted_as) }

          let(:test_class) do
            Class.new(described_class) do
              set_variants do
                { testing: { resize_to_fit: [200, 100] } }
              end
            end
          end

          it "returns a URL to the variant" do
            expect(subject.variant_url(:testing)).to match(%r{^http://localhost:#{default_port}/rails/active_storage/representations/redirect/.*/avatar.jpg$})
          end
        end
      end

      context "with test environment" do
        it_behaves_like "development local storage protocol options"
      end

      context "with development environment" do
        before do
          allow(Rails.env).to receive(:development?).and_return(true)
        end

        it_behaves_like "development local storage protocol options"
      end

      context "with production environment" do
        let(:hostname) { "production.decidim.test" }

        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        it "returns a default URL" do
          expect(subject.variant_url(:testing)).to match(%r{^http://production.decidim.test/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
        end

        context "and the PORT environment variable is defined as 443" do
          let(:local_port) { 443 }

          it "returns a URL containing the protocol only" do
            expect(subject.variant_url(:testing)).to match(%r{^https://production.decidim.test/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
          end
        end

        context "and the PORT environment variable is defined as 8080" do
          let(:local_port) { 8080 }

          it "returns a URL containing the port" do
            expect(subject.variant_url(:testing)).to match(%r{^http://production.decidim.test:8080/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
          end
        end

        context "and force_ssl is enabled" do
          include_context "with force_ssl enabled"

          it "returns a URL containing the protocol only" do
            expect(subject.variant_url(:testing)).to match(%r{^https://production.decidim.test/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
          end

          context "and the PORT environment variable is defined as 8080" do
            let(:local_port) { 8080 }

            it "returns a URL containing the port and protocol" do
              expect(subject.variant_url(:testing)).to match(%r{^https://production.decidim.test:8080/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
            end
          end
        end
      end

      context "with CDN host defined in the secrets" do
        let(:cdn_host) { "https://cdn.example.org" }

        # Local env variables should not affect the CDN URLs
        let(:hostname) { "production.decidim.test" }
        let(:local_port) { 9999 }

        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:test?).and_return(false)
          allow(Rails.application.secrets).to receive(:dig).and_call_original
          allow(Rails.application.secrets).to receive(:dig).with(:storage, :cdn_host).and_return(cdn_host)
        end

        it "returns a URL containing the CDN configurations" do
          expect(subject.variant_url(:testing)).to match(%r{^https://cdn.example.org/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
        end
      end
    end
  end
end
