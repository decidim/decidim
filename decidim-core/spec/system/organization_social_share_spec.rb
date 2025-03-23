# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/social_share_examples"

describe "Social shares" do
  let(:organization) { create(:organization, description:) }
  let!(:static_page) { create(:static_page, :public, content:, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let(:description) { { en: "Description <p><img src=\"#{description_image_path}\"></p>" } }
  let(:content) { { en: "Content <p><img src=\"#{content_image_path}\"></p>" } }
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:content_image_path) { Rails.application.routes.url_helpers.rails_blob_path(content_image, only_path: true) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:content_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "content_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:block_attachment_file) { Decidim::Dev.test_file("icon.png", "image/png") }
  let(:resource) { organization }

  before do
    if content_block
      content_block.images_container.background_image = block_attachment_file
      content_block.save!
    end
    switch_to_host(organization.host)
  end

  it_behaves_like "a social share meta tag", "description_image.jpg"

  context "when no description images" do
    let(:description_image_path) { "" }

    it_behaves_like "a social share meta tag", "icon.png"
  end

  context "when nothing" do
    let(:description_image_path) { "" }
    let(:content_block) { nil }

    it_behaves_like "a empty social share meta tag"
  end

  context "when visiting static pages" do
    let(:resource) { decidim.page_path(static_page, locale: I18n.locale) }

    it_behaves_like "a social share meta tag", "content_image.jpg"

    context "when no content images" do
      let(:content_image_path) { "" }

      it_behaves_like "a social share meta tag", "icon.png"
    end
  end
end
