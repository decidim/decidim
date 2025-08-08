# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::ParticipatorySpaceHeroCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:scope_name) { :participatory_process_homepage }
  let(:scoped_resource_id) { participatory_process.id }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name:, scoped_resource_id:, settings:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  context "when the content block has no settings" do
    it "shows the default contents" do
      expect(subject).to have_text(translated(participatory_process.title))
      expect(subject).to have_text(translated(participatory_process.subtitle))
    end
  end

  context "when the content block has customized the button text and url setting values" do
    let(:settings) do
      {
        button_text_en: "This is my button text",
        button_url_en: "/example"
      }
    end

    it "shows a button with the text and the url" do
      expect(subject).to have_link("This is my button text", href: "/example")
      expect(subject).to have_css("a[data-cta]")
    end
  end

  describe "when the content block has missing settings" do
    context "without the button url" do
      let(:settings) do
        {
          button_text_en: "This is my button text"
        }
      end

      it "does not show the button" do
        expect(subject).to have_no_link("This is my button text")
        expect(subject).to have_no_css("a[data-cta]")
      end
    end

    context "without the button text" do
      let(:settings) do
        {
          button_url_en: "/example"
        }
      end

      it "does not show the button" do
        expect(subject).to have_no_link(href: "/example")
        expect(subject).to have_no_css("a[data-cta]")
      end
    end
  end

  context "when the content block has a hero image" do
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
      style = subject.find("section")["style"]
      background_url = style.match(/background-image:url\('([^']+)'\)/)[1]
      expect(background_url).to be_blob_url(content_block.images_container.background_image.blob)
    end
  end
end
