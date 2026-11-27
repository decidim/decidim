# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::BlobRenderer do
    let(:renderer) { described_class.new(content) }
    let(:current_host) { "https://example.lvh.me" }

    let(:organization) { create(:organization) }
    let(:public_record) { create(:dummy_resource, organization:) }
    let(:image_blob) { create(:editor_image, organization:).file.blob }
    let(:document_blob) { create(:attachment, :with_pdf, attached_to: public_record).file.blob }
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
    let(:document_blob_url) { routes.rails_disk_service_url(document_blob.signed_id, document_blob.filename, host: asset_host) }
    let(:invalid_blob_url) { image_blob.to_global_id.to_s.gsub("Blob/", "Blob/123") }
    let(:suffix) { "" }

    let(:content) do
      <<~HTML.squish
        <p><img src="#{image_blob.to_global_id}/#{image_variant_encoded}#{suffix}" alt="Representation image"></p>
        <p><img src="#{image_blob.to_global_id}/#{image_variant_processed_encoded}#{suffix}" alt="Representation image processed"></p>
        <p><img src='#{image_blob.to_global_id}#{suffix}' alt="Blob image"></p>
        <p><a href='#{document_blob.to_global_id}#{suffix}'>Link to document</a></p>
        <p class="document-url">#{document_blob.to_global_id}#{suffix}</p>
        <p><img src="#{invalid_blob_url}" alt="Invalid blob"></p>
      HTML
    end

    before do
      ActiveStorage::Current.url_options = { host: current_host } if current_host
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
          # Note, the invalid blob URL is replaced with an empty string,
          # This might change in the future if we decide to keep the invalid URL instead of removing it
          expect(doc.at("img[alt='Invalid blob']").attr(:src)).to be_blank
        end
      end

      it_behaves_like "correctly rendered blob URLs"

      context "when current host is not set" do
        let(:current_host) { nil }

        it_behaves_like "correctly rendered blob URLs"
      end

      context "when blob GID is inside a code tag" do
        let(:content) do
          <<~HTML.squish
            <p><code>#{image_blob.to_global_id}</code></p>
          HTML
        end

        it "does not replace blob GID inside code tags" do
          rendered = Loofah.fragment(subject)
          code = rendered.at_css("code")

          expect(code.text).to eq(image_blob.to_global_id.to_s)
        end
      end

      context "when blob GID is inside a pre tag" do
        let(:content) do
          <<~HTML.squish
            <pre>Image URL: #{image_blob.to_global_id}</pre>
          HTML
        end

        it "does not replace blob GID inside pre tags" do
          rendered = Loofah.fragment(subject)
          pre = rendered.at_css("pre")

          expect(pre.text).to include(image_blob.to_global_id.to_s)
        end
      end

      context "when blob GID is inside a script tag" do
        let(:content) do
          <<~HTML.squish
            <script>var blobId = "#{image_blob.to_global_id}";</script>
          HTML
        end

        it "does not replace blob GID inside script tags" do
          rendered = Loofah.fragment(subject)
          script = rendered.at_css("script")

          expect(script.text).to include(image_blob.to_global_id.to_s)
        end
      end

      context "when blob GID is inside a style tag" do
        let(:content) do
          <<~HTML.squish
            <style>.bg { background: url('#{image_blob.to_global_id}'); }</style>
          HTML
        end

        it "does not replace blob GID inside style tags" do
          rendered = Loofah.fragment(subject)
          style = rendered.at_css("style")

          expect(style.text).to include(image_blob.to_global_id.to_s)
        end
      end

      context "when there is a query string after the gid" do
        let(:suffix) { "?some=strange&suffix=after" }

        it_behaves_like "correctly rendered blob URLs"
      end

      context "when there is some strange suffix after the gid" do
        let(:suffix) { "%something" }

        it_behaves_like "correctly rendered blob URLs"
      end

      context "when the blob is attached to a private record" do
        let(:private_export) { create(:private_export, organization:) }
        let(:content) { %(<p>#{private_export.file.blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "renders the private download path instead of an Active Storage URL" do
          expect(subject).to include("/private_downloads/")
          expect(subject).not_to include("/rails/active_storage/")
        end
      end

      context "when the blob is attached to an attachment in a restricted space" do
        let(:restricted_process) { create(:participatory_process, :restricted, organization:) }
        let(:attachment) { create(:attachment, :with_image, attached_to: restricted_process) }
        let(:content) { %(<p>#{attachment.file.blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "renders the private download path instead of an Active Storage URL" do
          expect(subject).to include("/private_downloads/")
          expect(subject).not_to include("/rails/active_storage/")
        end
      end

      context "when the blob is attached to a private record of another organization" do
        let(:other_organization) { create(:organization) }
        let(:private_export) { create(:private_export, organization: other_organization) }
        let(:content) { %(<p>#{private_export.file.blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "does not render the blob" do
          expect(subject).not_to include("/private_downloads/")
          expect(subject).not_to include("/rails/active_storage/")
          expect(Nokogiri::HTML(subject).at("p").text).to be_blank
        end
      end

      context "when the blob is attached to an attachment in a restricted space of another organization" do
        let(:other_organization) { create(:organization) }
        let(:restricted_process) { create(:participatory_process, :restricted, organization: other_organization) }
        let(:attachment) { create(:attachment, :with_image, attached_to: restricted_process) }
        let(:content) { %(<p>#{attachment.file.blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "does not render the blob" do
          expect(subject).not_to include("/private_downloads/")
          expect(subject).not_to include("/rails/active_storage/")
          expect(Nokogiri::HTML(subject).at("p").text).to be_blank
        end
      end

      context "when the organization is unknown and the blob is attached to a private record" do
        let(:private_export) { create(:private_export, organization:) }
        let(:content) { %(<p>#{private_export.file.blob.to_global_id}</p>) }

        before { RequestStore.store[:current_organization] = nil }

        it "renders the private download path" do
          expect(renderer.render).to include("/private_downloads/")
          expect(renderer.render).not_to include("/rails/active_storage/")
        end
      end

      context "when the blob is not attached to any record" do
        let(:unattached_blob) { create(:blob, :image) }
        let(:content) { %(<p>#{unattached_blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "does not render a blob URL" do
          expect(subject).not_to include("/rails/active_storage/")
          expect(Nokogiri::HTML(subject).at("p").text).to be_blank
        end
      end

      context "when the blob belongs to another organization" do
        let(:other_organization) { create(:organization) }
        let(:other_editor_image) { create(:editor_image, organization: other_organization) }
        let(:content) { %(<p>#{other_editor_image.file.blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "does not render a blob URL" do
          expect(subject).not_to include("/rails/active_storage/")
          expect(Nokogiri::HTML(subject).at("p").text).to be_blank
        end
      end

      context "when the organization is only available in the request store" do
        around do |example|
          RequestStore.store[:current_organization] = organization
          example.run
        ensure
          RequestStore.store[:current_organization] = nil
        end

        context "when the blob belongs to the current organization" do
          let(:content) { %(<p>#{image_blob.to_global_id}</p>) }

          it "renders the blob URL" do
            expect(Nokogiri::HTML(renderer.render).at("p").inner_html).to be_blob_url(image_blob)
          end
        end

        context "when the blob belongs to another organization" do
          let(:other_organization) { create(:organization) }
          let(:other_editor_image) { create(:editor_image, organization: other_organization) }
          let(:content) { %(<p>#{other_editor_image.file.blob.to_global_id}</p>) }

          it "does not render a blob URL" do
            expect(renderer.render).not_to include("/rails/active_storage/")
            expect(Nokogiri::HTML(renderer.render).at("p").text).to be_blank
          end
        end

        context "when the blob is attached to a private record of another organization" do
          let(:other_organization) { create(:organization) }
          let(:private_export) { create(:private_export, organization: other_organization) }
          let(:content) { %(<p>#{private_export.file.blob.to_global_id}</p>) }

          it "does not render the blob" do
            expect(renderer.render).not_to include("/private_downloads/")
            expect(Nokogiri::HTML(renderer.render).at("p").text).to be_blank
          end
        end
      end

      context "when the blob belongs to the current organization" do
        let(:content) { %(<p>#{image_blob.to_global_id}</p>) }

        subject { renderer.render(organization:) }

        it "renders the blob URL" do
          expect(Nokogiri::HTML(subject).at("p").inner_html).to be_blob_url(image_blob)
        end
      end
    end
  end
end
