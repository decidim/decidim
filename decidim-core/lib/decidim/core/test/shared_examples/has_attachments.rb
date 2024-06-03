# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has attachments content blocks" do
  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }

    let!(:image) { create(:attachment, attached_to:) }

    before do
      visit current_path
    end

    it "shows them" do
      within "[data-content] .documents__container" do
        expect(page).to have_content(translated(document.title))
      end

      within "[data-content] [data-gallery]" do
        expect(page).to have_css("img")
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_pdf, attached_to:, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to:, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to:, weight: 2) }
    let!(:first_image) { create(:attachment, attached_to:, weight: 1) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      within "[data-content] .documents__container" do
        expect(decidim_escape_translated(first_document.title).gsub("&quot;", "\"")).to appear_before(decidim_escape_translated(last_document.title).gsub("&quot;", "\""))
      end

      within "[data-content] [data-gallery]" do
        expect(strip_tags(translated(first_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end

shared_examples_for "has attachments tabs" do
  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }
    let!(:link) { create(:attachment, :with_link, attached_to:) }
    let!(:image) { create(:attachment, attached_to:) }

    before do
      visit current_path
    end

    it "shows them" do
      find("li [data-controls='panel-documents']").click
      within "#panel-documents" do
        expect(page).to have_content(translated(document.title))
        expect(page).to have_content(translated(link.title))
      end

      find("li [data-controls='panel-images']").click
      within "#panel-images" do
        expect(page).to have_css("img")
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_link, attached_to:, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to:, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to:, weight: 2) }
    let!(:first_image) { create(:attachment, attached_to:, weight: 1) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      find("li [data-controls='panel-documents']").click
      within "#panel-documents" do
        expect(decidim_escape_translated(first_document.title).gsub("&quot;", "\"")).to appear_before(decidim_escape_translated(last_document.title).gsub("&quot;", "\""))
      end

      find("li [data-controls='panel-images']").click
      within "#panel-images" do
        expect(strip_tags(translated(first_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end
