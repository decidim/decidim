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
        expect(page).to have_content(/#{translated(document.title, locale: :en)}/i)
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
    let!(:fist_image) { create(:attachment, attached_to:, weight: 1) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      within "[data-content] .documents__container" do
        expect(translated(first_document.title, locale: :en)).to appear_before(translated(last_document.title, locale: :en))
      end

      within "[data-content] [data-gallery]" do
        expect(strip_tags(translated(fist_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end

shared_examples_for "has attachments tabs" do
  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }

    let!(:image) { create(:attachment, attached_to:) }

    before do
      visit current_path
    end

    it "shows them" do
      find("li [data-controls='panel-documents']").click
      within "#panel-documents" do
        expect(page).to have_content(/#{translated(document.title, locale: :en)}/i)
      end

      find("li [data-controls='panel-images']").click
      within "#panel-images" do
        expect(page).to have_css("img")
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_pdf, attached_to:, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to:, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to:, weight: 2) }
    let!(:fist_image) { create(:attachment, attached_to:, weight: 1) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      find("li [data-controls='panel-documents']").click
      within "#panel-documents" do
        expect(translated(first_document.title, locale: :en)).to appear_before(translated(last_document.title, locale: :en))
      end

      find("li [data-controls='panel-images']").click
      within "#panel-images" do
        expect(strip_tags(translated(fist_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end
