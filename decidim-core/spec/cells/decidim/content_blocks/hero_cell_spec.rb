# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HeroCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization:, manifest_name: :hero, scope_name: :homepage, settings: }
  let(:settings) { {} }

  controller Decidim::PagesController

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
      expect(subject.to_s).to include(content_block.images_container.attached_uploader(:background_image).path(variant: :big))
    end
  end

  describe "#cache_hash" do
    it "generate a unique hash" do
      content_block.reload
      old_hash = cell(content_block.cell, content_block).send(:cache_hash)
      content_block.reload

      expect(cell(content_block.cell, content_block).send(:cache_hash)).to eq(old_hash)
    end

    context "when model is updated" do
      it "generates a different hash" do
        old_hash = cell(content_block.cell, content_block).send(:cache_hash)
        content_block.update!(weight: 2)
        content_block.reload

        expect(cell(content_block.cell, content_block).send(:cache_hash)).not_to eq(old_hash)
      end
    end

    context "when organization is updated" do
      it "generates a different hash" do
        old_hash = cell(content_block.cell, content_block).send(:cache_hash)
        controller.current_organization.update!(name: "New name")
        controller.current_organization.reload

        expect(cell(content_block.cell, content_block).send(:cache_hash)).not_to eq(old_hash)
      end
    end

    context "when current locale change" do
      let(:alt_locale) { :ca }

      before do
        allow(I18n).to receive(:locale).and_return(alt_locale)
      end

      it "generates a different hash" do
        expect(cell(content_block.cell, content_block).send(:cache_hash)).not_to match(/en$/)
      end
    end
  end
end
