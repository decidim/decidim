# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HeroComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage, settings:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  context "when the content block has no settings" do
    it "shows the default welcome text" do
      render_inline(subject)

      expect(page).to have_text("Welcome to #{organization.name}")
    end
  end

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "welcome_text_en" => "This is my welcome text"
      }
    end

    it "shows the custom welcome text" do
      render_inline(subject)

      expect(page).to have_text("This is my welcome text")
    end
  end

  context "when the content block has a background image" do
    let(:background_image) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    before do
      content_block.images_container.background_image = background_image
      content_block.save
    end

    it "uses that image's big version as background" do
      result = render_inline(subject)

      expect(result.to_s).to include(content_block.images_container.attached_uploader(:background_image).path(variant: :big))
    end
  end
end
