# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HighlightedContentBannerCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :highlighted_content_banner, scope_name: :homepage, settings:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  context "when the content block has no settings" do
    it "does not render" do
      # It still renders a "<!DOCTYPE html..."
      expect(subject.to_s.length).to be <= 150
    end
  end

  context "when the content block has all the necessary settings" do
    let(:settings) do
      {
        "title_en" => "Hello world",
        "short_description_en" => "Bye world",
        "action_button_title_en" => "Go!",
        "action_button_subtitle_en" => "Now",
        "action_button_url" => "https://example.org"
      }
    end

    it "shows the title_en" do
      expect(subject).to have_text("Hello world")
    end

    it "shows the subtitle_en" do
      expect(subject).to have_text("Bye world")
    end

    it "shows the action_button_title_en" do
      expect(subject).to have_text("Go!")
    end

    it "shows the action_button_subtitle_en" do
      expect(subject).to have_text("Now")
    end

    it "shows the cta_button_path" do
      expect(subject).to have_link(href: "https://example.org")
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
        expect(subject.to_s).to include(content_block.images_container.attached_uploader(:background_image).variant_url(:big))
      end
    end
  end
end
