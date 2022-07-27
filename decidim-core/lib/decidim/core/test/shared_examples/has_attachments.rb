# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has attachments" do
  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }

    let!(:image) { create(:attachment, attached_to:) }

    before do
      visit current_path
    end

    it "shows them" do
      within "div.wrapper .documents" do
        expect(page).to have_content(/#{translated(document.title, locale: :en)}/i)
      end

      within "div.wrapper .images" do
        expect(page).to have_css("img.thumbnail")
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
      within "div.wrapper .documents" do
        expect(translated(first_document.title, locale: :en)).to appear_before(translated(last_document.title, locale: :en))
      end

      within "div.wrapper .images" do
        expect(strip_tags(translated(fist_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end
