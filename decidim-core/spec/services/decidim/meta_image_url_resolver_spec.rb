# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetaImageUrlResolver do
  subject { described_class.new(resource, organization).resolve }

  let(:organization) { create(:organization) }
  let(:hero_image) { nil }
  let(:avatar) { nil }
  let(:participatory_space) { create(:assembly, organization:, hero_image:) }
  let(:component) { create(:proposal_component, :with_attachments_allowed, participatory_space:) }
  let!(:proposal) { create(:proposal, component:, body:) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("dni.jpg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let!(:description_editor_image) do
    create(:editor_image, organization:).tap do |editor_image|
      editor_image.file.attach(description_image)
    end
  end
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:body) do
    { en: "<p><img src=\"#{description_image_path}\"></p>" }
  end
  let(:attachment_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
  let!(:attachment) { create(:attachment, file: attachment_file, attached_to: proposal) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let(:block_attachment_file) { Decidim::Dev.test_file("icon.png", "image/png") }
  let!(:user) { create(:user, organization:, avatar:) }

  before do
    if block_attachment_file
      content_block.images_container.background_image = block_attachment_file
      content_block.save
    end
  end

  shared_examples "direct images" do
    let(:hero_image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    it { is_expected.to end_with("/city.jpeg") }

    context "and no hero_image" do
      let(:hero_image) { nil }

      it { is_expected.to end_with("/icon.png") }
    end
  end

  shared_examples "content block images" do
    it { is_expected.to end_with("/icon.png") }
  end

  context "when there is no image attached" do
    let(:hero_image) { nil }
    let(:resource) { nil }

    before do
      FileUtils.rm(Rails.root.glob("tmp/storage/**/**/#{content_block.images_container.background_image.blob.key}"))
    end

    it { is_expected.to be_nil }
  end

  context "when avatar image" do
    let(:avatar) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    let(:resource) { user }

    it { is_expected.to end_with("/avatar.jpg") }
  end

  context "when the resource has direct images" do
    let(:resource) { participatory_space }

    it_behaves_like "direct images"
    it_behaves_like "content block images"
  end

  context "when no direct images attachment images are present" do
    let(:resource) { proposal }

    it { is_expected.to end_with("/city3.jpeg") }
  end

  context "when no attachments and description image is present" do
    let(:resource) { proposal }
    let(:attachment) { nil }

    it { is_expected.to end_with("/description_image.jpg") }
  end

  context "when no attachments and description image is present as GlobalID" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:body) do
      { en: "<p><img src=\"#{description_image.to_global_id}\"></p>" }
    end

    it { is_expected.to end_with("/description_image.jpg") }
  end

  context "when no attachments and description image is present as GlobalID with a variation" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:variation) { Base64.strict_encode64(ActiveSupport::JSON.encode({ resize_to_limit: [100, 100] })) }
    let(:body) do
      { en: "<p><img src=\"#{description_image.to_global_id}/#{variation}\"></p>" }
    end

    it { is_expected.to end_with("/description_image.jpg") }
  end

  context "when no attachments and the first description image is a GlobalID for a missing blob" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:deleted_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "deleted.jpg",
        content_type: "image/jpeg"
      )
    end
    let(:deleted_blob_gid) do
      deleted_blob.to_global_id.tap { deleted_blob.destroy }
    end
    let(:body) do
      { en: "<p><img src=\"#{deleted_blob_gid}\"><img src=\"#{description_image.to_global_id}\"></p>" }
    end

    it "skips the missing blob and uses the next valid editor image" do
      expect { subject }.not_to raise_error
      expect(subject).to end_with("/description_image.jpg")
    end
  end

  context "when the description has more images than the inspection limit" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:rejected_images) do
      Array.new(described_class::MAX_DESCRIPTION_IMAGES) do |index|
        "<img src=\"https://example.org/images/rejected-#{index}.png\">"
      end
    end
    let(:body) do
      { en: "<p>#{rejected_images.join}<img src=\"#{description_image.to_global_id}\"></p>" }
    end

    it "does not inspect images past the limit" do
      expect(subject).to be_nil
    end

    context "when a lower priority image is available" do
      let(:hero_image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

      it "falls back to the lower priority image" do
        expect(subject).to end_with("/city.jpeg")
      end
    end
  end

  context "when the description repeats the same rejected image" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:rejected_images) do
      Array.new(described_class::MAX_DESCRIPTION_IMAGES * 2) do
        "<img src=\"https://example.org/images/rejected.png\">"
      end
    end
    let(:body) do
      { en: "<p>#{rejected_images.join}<img src=\"#{description_image.to_global_id}\"></p>" }
    end

    it "inspects the repeated source only once" do
      expect(subject).to end_with("/description_image.jpg")
    end
  end

  context "when the description image is referenced by a bare blob id" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:description_image_path) { "/rails/active_storage/blobs/#{description_image.id}" }

    it { is_expected.to be_nil }
  end

  context "when the description image is an orphan blob referenced by global id" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:orphan_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "orphan.jpg",
        content_type: "image/jpeg"
      )
    end
    let(:body) do
      { en: "<p><img src=\"#{orphan_blob.to_global_id}\"></p>" }
    end

    it { is_expected.to be_nil }
  end

  context "when the description image is an orphan blob referenced by signed id" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:orphan_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "orphan.jpg",
        content_type: "image/jpeg"
      )
    end
    let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(orphan_blob, only_path: true) }

    it { is_expected.to be_nil }
  end

  context "when the description image belongs to an editor image from another organization" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:other_organization) { create(:organization) }
    let(:foreign_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "foreign.jpg",
        content_type: "image/jpeg"
      )
    end
    let!(:foreign_editor_image) do
      create(:editor_image, organization: other_organization).tap do |editor_image|
        editor_image.file.attach(foreign_blob)
      end
    end
    let(:body) do
      { en: "<p><img src=\"#{foreign_blob.to_global_id}\"></p>" }
    end

    it { is_expected.to be_nil }
  end

  context "when the description image is a verification attachment from the same organization" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:verification_user) { create(:user, :confirmed, organization:) }
    let!(:authorization) do
      create(
        :authorization,
        :pending,
        user: verification_user,
        verification_attachment: Decidim::Dev.test_file("dni.jpg", "image/jpeg")
      )
    end
    let(:body) do
      { en: "<p><img src=\"#{authorization.verification_attachment.blob.to_global_id}\"></p>" }
    end

    it { is_expected.to be_nil }
  end

  context "when the description image is a verification attachment from another organization" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:block_attachment_file) { nil }
    let(:other_organization) { create(:organization) }
    let(:verification_user) { create(:user, :confirmed, organization: other_organization) }
    let!(:authorization) do
      create(
        :authorization,
        :pending,
        user: verification_user,
        verification_attachment: Decidim::Dev.test_file("dni.jpg", "image/jpeg")
      )
    end
    let(:body) do
      { en: "<p><img src=\"#{authorization.verification_attachment.blob.to_global_id}\"></p>" }
    end

    it { is_expected.to be_nil }
  end

  context "when no previous images and belongs to a participatory space" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:description_image_path) { "" }

    it_behaves_like "direct images"
    it_behaves_like "content block images"
  end
end
