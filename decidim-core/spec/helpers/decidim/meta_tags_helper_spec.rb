# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MetaTagsHelper do
    subject { helper }

    let(:base_url) { "http://#{host}" }
    let(:host) { "test.host" }

    describe "#add_base_url_to" do
      context "with image path" do
        let(:path) { "/rails/active_storage/disk/123--foobar/banner_image.jpeg" }

        it "adds base url to path" do
          expect(subject.add_base_url_to(path)).to eq("#{base_url}#{path}")
        end
      end

      context "when path includes base url already" do
        let(:path) { "#{base_url}/rails/active_storage/disk/123--foobar/banner_image.jpeg" }

        it "does not duplicate base url" do
          expect(subject.add_base_url_to(path)).to eq(path)
        end
      end
    end

    describe "#resolve_base_url" do
      it "returns base url" do
        expect(subject.resolve_base_url).to eq(base_url)
      end

      context "when there is no request" do
        let!(:current_organization) { create(:organization, host:) }

        before do
          allow(subject).to receive(:request).and_return(nil)
        end

        it "still returns base url" do
          allow(subject).to receive(:current_organization).and_return(current_organization)
          expect(subject.resolve_base_url).to eq(base_url)
        end
      end
    end
  end
end
