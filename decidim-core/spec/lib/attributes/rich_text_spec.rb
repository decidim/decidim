# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::RichText do
    let(:attribute) { described_class.new }

    describe "#type" do
      it "returns :decidim/attributes/rich_text" do
        expect(subject.type).to be(:"decidim/attributes/rich_text")
      end
    end

    describe "#serialize" do
      subject { attribute.serialize(value) }

      context "with a regular string value" do
        let(:value) { "foo" }

        it "returns the unconverted value" do
          expect(subject).to eq(value)
        end
      end

      context "when the string includes a blob URL" do
        let(:current_host) { "https://example.lvh.me" }
        let(:image_blob) { create(:blob, :image) }
        let(:value) do
          <<~HTML.squish
            <p><img src="#{image_blob.url}" alt="Image blob"></p>
          HTML
        end

        before do
          ActiveStorage::Current.url_options = { host: current_host }
        end

        it "converts the blob URL to a blob reference" do
          expect(subject).to eq(
            <<~HTML.squish
              <p><img src="#{image_blob.to_global_id}" alt="Image blob"></p>
            HTML
          )
        end
      end
    end

    describe "#cast" do
      subject { attribute.cast(value) }

      context "with a regular string value" do
        let(:value) { "foo" }

        it "returns the unconverted value" do
          expect(subject).to eq(value)
        end
      end

      context "when the string includes a reference to a blob" do
        let(:current_host) { "https://example.lvh.me" }
        let(:image_blob) { create(:blob, :image) }
        let(:value) do
          <<~HTML.squish
            <p><img src="#{image_blob.to_global_id}" alt="Image blob"></p>
          HTML
        end

        before do
          ActiveStorage::Current.url_options = { host: current_host }
        end

        it "converts the blob reference to a blob URL" do
          doc = Nokogiri::HTML(subject)

          blob_regex = %r{/rails/active_storage/disk/([^/]+)/[^/]}
          image_src = doc.at("img").attr(:src)
          expect(image_src).to match(blob_regex)

          expect(image_src).to be_blob_url(image_blob)
        end
      end

      context "when the string includes an unsafe blob variation" do
        let(:current_host) { "https://example.lvh.me" }
        let(:image_blob) { create(:blob, :image) }
        let(:unsafe_variation) do
          Base64.strict_encode64(ActiveSupport::JSON.encode("instance_eval" => "1", "format" => "png"))
        end
        let(:value) do
          <<~HTML.squish
            <p><img src="#{image_blob.to_global_id}/#{unsafe_variation}" alt="Image blob"></p>
          HTML
        end

        before do
          ActiveStorage::Current.url_options = { host: current_host }
        end

        it "falls back to the original blob URL" do
          expect(subject).not_to include("/rails/active_storage/representations/")
          expect(Nokogiri::HTML(subject).at("img").attr(:src)).to be_blob_url(image_blob)
        end
      end
    end
  end
end
