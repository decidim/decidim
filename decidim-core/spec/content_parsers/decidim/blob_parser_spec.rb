# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::BlobParser do
    let(:parser) { described_class.new(content, context) }
    let(:context) { {} }

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
    let(:image_representation_url) { routes.rails_representation_url(image_variant, host: asset_host) }
    let(:image_representation_proxy_path) { routes.rails_blob_representation_proxy_path(image_blob.signed_id, ActiveStorage.verifier.generate(image_variant_processed_transforms, purpose: :variation), image_blob.filename, only_path: true) }
    let(:image_representation_proxy_url) { routes.rails_blob_representation_proxy_url(image_blob.signed_id, ActiveStorage.verifier.generate(image_variant_processed_transforms, purpose: :variation), image_blob.filename, host: asset_host) }
    let(:image_blob_path) { routes.rails_blob_path(image_blob, only_path: true) }
    let(:image_blob_url) { routes.rails_blob_url(image_blob, host: asset_host) }
    let(:document_blob_path) { routes.rails_blob_path(document_blob, only_path: true) }
    let(:document_blob_url) { routes.rails_blob_url(document_blob, host: asset_host) }
    let(:document_blob_proxy_path) { routes.rails_service_blob_proxy_path(document_blob.signed_id, document_blob.filename, only_path: true) }
    let(:document_blob_proxy_url) { routes.rails_service_blob_proxy_url(document_blob.signed_id, document_blob.filename, host: asset_host) }
    let(:document_blob_disk_url) { document_blob.url }

    let(:content) do
      <<~HTML.squish
        <p><img src="#{image_representation_path}" alt="Representation image (path)"></p>
        <p><img src="#{image_representation_url}" alt="Representation image (url)"></p>
        <p><img src="#{image_representation_proxy_path}" alt="Representation image proxy (path)"></p>
        <p><img src="#{image_representation_proxy_url}" alt="Representation image proxy (url)"></p>
        <p><img src='#{image_blob_path}' alt="Blob image path"></p>
        <p><img src='#{image_blob_url}' alt="Blob image URL"></p>
        <p><a href='#{document_blob_path}'>Link to document</a></p>
        <p>#{document_blob_url}</p>
        <p>#{document_blob_proxy_path}</p>
        <p>#{document_blob_proxy_url}</p>
        <p>#{document_blob_disk_url}</p>
      HTML
    end
    let(:parsed_content) do
      <<~HTML.squish
        <p><img src="#{image_blob.to_global_id}/#{image_variant_encoded}" alt="Representation image (path)"></p>
        <p><img src="#{image_blob.to_global_id}/#{image_variant_encoded}" alt="Representation image (url)"></p>
        <p><img src="#{image_blob.to_global_id}/#{image_variant_processed_encoded}" alt="Representation image proxy (path)"></p>
        <p><img src="#{image_blob.to_global_id}/#{image_variant_processed_encoded}" alt="Representation image proxy (url)"></p>
        <p><img src='#{image_blob.to_global_id}' alt="Blob image path"></p>
        <p><img src='#{image_blob.to_global_id}' alt="Blob image URL"></p>
        <p><a href='#{document_blob.to_global_id}'>Link to document</a></p>
        <p>#{document_blob.to_global_id}</p>
        <p>#{document_blob.to_global_id}</p>
        <p>#{document_blob.to_global_id}</p>
        <p>#{document_blob.to_global_id}</p>
      HTML
    end

    before do
      ActiveStorage::Current.url_options = { host: "https://example.lvh.me" }
    end

    describe "#rewrite" do
      subject { parser.rewrite }

      it "creates rewrites the URLs correctly" do
        expect(subject).to eq(parsed_content)
      end

      context "when content is preceded by a link with an URL" do
        let(:parser) { described_class.new(content_with_url, context) }
        let(:content_with_url) do
          <<~HTML.squish
            <p><a href='https://example.org/document.pdf'>Link to document</a></p>
            #{content}
          HTML
        end
        let(:parsed_content_with_url) do
          <<~HTML.squish
            <p><a href='https://example.org/document.pdf'>Link to document</a></p>
            #{parsed_content}
          HTML
        end

        it "rewrites the URLs correctly" do
          expect(subject).to eq(parsed_content_with_url)
        end
      end
    end
  end
end
