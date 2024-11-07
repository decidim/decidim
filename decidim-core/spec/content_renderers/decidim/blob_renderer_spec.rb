# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::BlobRenderer do
    let(:renderer) { described_class.new(content) }
    let(:current_host) { "https://example.lvh.me" }

    let(:image_blob) { create(:blob, :image) }
    let(:document_blob) { create(:blob, :document) }
    let(:image_variant) { image_blob.variant(image_variant_transforms) }
    let(:image_variant_transforms) { { format: "png", resize_to_limit: [100, 100] } }
    let(:image_variant_encoded) { Base64.strict_encode64(ActiveSupport::JSON.encode(image_variant_transforms)) }

    let(:image_variant_processed) { image_blob.variant(image_variant_processed_transforms).processed }
    let(:image_variant_processed_transforms) { { format: "jpeg", resize_to_limit: [20, 20] } }
    let(:image_variant_processed_encoded) { Base64.strict_encode64(ActiveSupport::JSON.encode(image_variant_processed_transforms)) }

    let(:routes) { Rails.application.routes.url_helpers }
    let(:asset_host) { "http://example.lvh.me" }
    let(:image_representation_path) { routes.rails_representation_path(image_variant, only_path: true) }
    let(:image_variant_processed_representation_path) { routes.rails_representation_path(image_variant_processed, only_path: true) }
    let(:image_blob_url) { routes.rails_disk_service_url(image_blob.signed_id, image_blob.filename, host: asset_host) }
    let(:document_blob_url) { routes.rails_disk_service_url(document_blob.signed_id, image_blob.filename, host: asset_host) }

    let(:content) do
      <<~HTML.squish
        <p><img src="#{image_blob.to_global_id}/#{image_variant_encoded}" alt="Representation image"></p>
        <p><img src="#{image_blob.to_global_id}/#{image_variant_processed_encoded}" alt="Representation image processed"></p>
        <p><img src='#{image_blob.to_global_id}' alt="Blob image"></p>
        <p><a href='#{document_blob.to_global_id}'>Link to document</a></p>
        <p class="document-url">#{document_blob.to_global_id}</p>
      HTML
    end

    before do
      ActiveStorage::Current.host = current_host if current_host
    end

    describe "#render" do
      subject { renderer.render }

      shared_examples "correctly rendered blob URLs" do
        it "renders the correct result" do
          expect(subject).to match(%(<p><img src="#{image_representation_path}" alt="Representation image"></p>))
          expect(subject).to match(%(<p><img src="#{image_variant_processed_representation_path}" alt="Representation image processed"></p>))

          doc = Nokogiri::HTML(subject)
          expect(doc.at("img[alt='Blob image']").attr(:src)).to be_blob_url(image_blob)
          expect(doc.at("a").attr(:href)).to be_blob_url(document_blob)
          expect(doc.at("p.document-url").inner_html).to be_blob_url(document_blob)
        end
      end

      it_behaves_like "correctly rendered blob URLs"

      context "when current host is not set" do
        let(:current_host) { nil }

        it_behaves_like "correctly rendered blob URLs"
      end
    end
  end
end
