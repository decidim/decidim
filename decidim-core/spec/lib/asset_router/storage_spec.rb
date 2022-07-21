# frozen_string_literal: true

require "spec_helper"

module Decidim::AssetRouter
  describe Storage do
    subject { router }

    let(:router) { described_class.new(asset) }
    let(:asset) { organization.official_img_header }
    let(:organization) { create(:organization) }

    describe "#url" do
      subject { router.url(**options) }

      let(:options) { {} }
      let(:default_port) { Capybara.server_port }

      context "with an ActiveStorage::Attached" do
        it "creates the route to the blob" do
          expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
        end

        context "with extra URL options" do
          let(:options) { { port: nil, host: "custom.host", utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }

          it "handles the extra URL options correctly" do
            expect(subject).to match(%r{^http://custom.host/rails/active_storage/blobs/redirect/.*/avatar.jpg\?utm_campaign=testing&utm_medium=email&utm_source=website$})
          end
        end
      end

      context "with a variant" do
        let(:asset) { organization.official_img_header.variant(resize_to_fit: [160, 160]) }

        it "creates the route to the variant" do
          expect(subject).to match(%r{^http://localhost:#{default_port}/rails/active_storage/representations/redirect/.*/avatar.jpg$})
        end
      end

      context "when the CDN host is defined" do
        before do
          allow(Rails.application.secrets).to receive(:dig).and_call_original
          allow(Rails.application.secrets).to receive(:dig).with(:storage, :cdn_host).and_return("https://cdn.example.org")
        end

        it "creates the route to the CDN blob" do
          expect(subject).to match(%r{^https://cdn.example.org/rails/active_storage/blobs/redirect/.*/avatar.jpg$})
        end

        context "with extra URL options" do
          let(:options) { { utm_source: "website", utm_medium: "email", utm_campaign: "testing" } }

          it "handles the extra URL options correctly" do
            expect(subject).to match(%r{^https://cdn.example.org/rails/active_storage/blobs/redirect/.*/avatar.jpg\?utm_campaign=testing&utm_medium=email&utm_source=website$})
          end
        end
      end
    end
  end
end
