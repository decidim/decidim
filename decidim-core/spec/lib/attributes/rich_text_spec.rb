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
          ActiveStorage::Current.host = current_host
        end

        after do
          ActiveStorage::Current.host = nil
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
          ActiveStorage::Current.host = current_host
        end

        after do
          ActiveStorage::Current.host = nil
        end

        it "converts the blob reference to a blob URL" do
          doc = Nokogiri::HTML(subject)

          blob_regex = %r{/rails/active_storage/disk/([^/]+)/[^/]}
          image_src = doc.at("img").attr(:src)
          expect(image_src).to match(blob_regex)

          # TODO: Change to be_blob_url after merging PR https://github.com/decidim/decidim/pull/12576
          match = image_src.match(blob_regex)
          decoded = ActiveStorage.verifier.verified(match[1], purpose: :blob_key)
          blob = ActiveStorage::Blob.find_by(key: decoded[:key])
          expect(blob).to eq(image_blob)
        end
      end
    end
  end
end
