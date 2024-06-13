# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetaImageUrlResolver do
  subject { resolver }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:proposal_component, :with_attachments_allowed, participatory_space:) }
  let(:resource) { create(:proposal, component:) }
  let(:resolver) { described_class.new(resource, organization) }

  describe "#resolve" do
    context "when attachment image is present" do
      let(:attachment) { create(:attachment, :with_image, attached_to: resource) }

      before do
        allow(resource).to receive(:attachments).and_return([attachment])
      end

      it "returns the resized attachment image URL" do
        expect(subject.resolve).to include(attachment.file.filename.to_s)
      end
    end

    context "when description image is present" do
      let(:description_image) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city3.jpeg")),
          filename: "city3.jpeg",
          content_type: "image/jpeg"
        )
      end

      let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
      let(:html) { "<p><img src=\"#{description_image_path}\"></p>" }

      before do
        resource.update(body: { en: html })
      end

      it "returns the resized description image URL" do
        expect(subject.resolve).to include(description_image.filename.to_s)
      end
    end

    context "when participatory space image is present" do
      let(:hero_image) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city2.jpeg")),
          filename: "hero_image.jpeg",
          content_type: "image/jpeg"
        )
      end

      let(:participatory_space) { create(:participatory_process, organization:, hero_image:) }

      before do
        allow(resource).to receive(:participatory_space).and_return(participatory_space)
      end

      it "returns the resized participatory space image URL" do
        expect(subject.resolve).to include(hero_image.filename.to_s)
      end
    end

    context "when content block image is present" do
      let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
      let(:attachment) { create(:attachment, :with_image, attached_to: content_block) }

      before do
        allow(Decidim::ContentBlock).to receive(:find_by).and_return(content_block)
        allow(content_block).to receive(:attachments).and_return([attachment])
      end

      it "returns the resized content block image URL" do
        expect(subject.resolve).to include(attachment.file.filename.to_s)
      end
    end
  end
end
