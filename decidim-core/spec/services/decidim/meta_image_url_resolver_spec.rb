# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetaImageUrlResolver do
  subject { described_class.new(resource, organization).resolve }

  let(:organization) { create(:organization) }
  let(:hero_image) { nil }
  let(:banner_image) { nil }
  let(:avatar) { nil }
  let(:participatory_space) { create(:assembly, organization:, hero_image:, banner_image:) }
  let(:component) { create(:proposal_component, :with_attachments_allowed, participatory_space:) }
  let!(:proposal) { create(:proposal, component:, body:) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("dni.jpg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
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
    let(:banner_image) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }

    it { is_expected.to end_with("/city.jpeg") }

    context "and no hero_image" do
      let(:hero_image) { nil }

      it { is_expected.to end_with("/city2.jpeg") }
    end
  end

  shared_examples "content block images" do
    it { is_expected.to end_with("/icon.png") }
  end

  context "when there is no image attached" do
    let(:hero_image) { nil }
    let(:banner_image) { nil }
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

  context "when no previous images and belongs to a participatory space" do
    let(:resource) { proposal }
    let(:attachment) { nil }
    let(:description_image_path) { "" }

    it_behaves_like "direct images"
    it_behaves_like "content block images"
  end
end
