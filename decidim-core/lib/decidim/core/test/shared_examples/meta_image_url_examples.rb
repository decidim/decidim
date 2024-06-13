# frozen_string_literal: true

require "spec_helper"

shared_examples "meta image url examples" do |expected_image_url|
  let!(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city3.jpeg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end

  let(:uploaded_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city2.jpeg")),
      filename: "default_hero_image.jpg",
      content_type: "image/jpeg"
    )
  end

  let(:images) do
    {
      "background_image" => uploaded_image.signed_id
    }
  end

  let(:form_klass) { Decidim::Admin::ContentBlockForm }
  let(:form) { form_klass.from_params(content_block: { images: }) }

  def meta_image_url
    find('meta[property="og:image"]', visible: false)[:content]
  rescue Capybara::ElementNotFound
    nil
  end

  def visit_resource
    visit resource_locator(resource).path
  end

  it "correctly resolves meta image URL" do
    visit_resource
    expect(meta_image_url).to include(expected_image_url)
  end
end
