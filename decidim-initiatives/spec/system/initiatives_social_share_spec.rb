# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/social_share_examples"

describe "Social shares" do
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, description:, scoped_type: initiative_type_scope, organization:) }
  let!(:initiative_type) { create(:initiatives_type, banner_image:, organization:) }
  let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }
  let!(:attachment) { create(:attachment, :with_image, attached_to: initiative, file: attachment_file) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let(:description) { { en: "Description <p><img src=\"#{description_image_path}\"></p>" } }
  let(:banner_image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
  let!(:attachment_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:block_attachment_file) { Decidim::Dev.test_file("icon.png", "image/png") }
  let(:resource) { initiative }

  before do
    if content_block
      content_block.images_container.background_image = block_attachment_file
      content_block.save!
    end
    switch_to_host(organization.host)
  end

  it_behaves_like "a social share meta tag", "city3.jpeg"
  it_behaves_like "a social share via QR code" do
    let(:card_image) { "city3.jpeg" }
  end

  context "when no attachments" do
    let(:attachment) { nil }

    it_behaves_like "a social share meta tag", "description_image.jpg"
  end

  context "when no attachments, description image" do
    let(:attachment) { nil }
    let(:description_image_path) { "" }

    it_behaves_like "a social share meta tag", "icon.png"
  end

  context "when listing all assemblies" do
    let(:resource) { decidim_initiatives.initiatives_path(locale: I18n.locale) }

    it_behaves_like "a social share meta tag", "icon.png"
  end
end
