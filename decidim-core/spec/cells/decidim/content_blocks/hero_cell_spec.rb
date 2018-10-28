# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HeroCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :hero, scope: :homepage, settings: settings }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows the default welcome text" do
      expect(subject).to have_text("Welcome to #{organization.name}")
    end
  end

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "welcome_text_en" => "This is my welcome text"
      }
    end

    it "shows the custom welcome text" do
      expect(subject).to have_text("This is my welcome text")
    end
  end

  context "when the content block has a background image" do
    let(:background_image) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
        "image/jpg"
      )
    end

    before do
      content_block.images_container.background_image = background_image
      content_block.save
    end

    it "uses that image's big version as background" do
      expect(subject.to_s).to include(content_block.images_container.background_image.big.url)
    end
  end
end
