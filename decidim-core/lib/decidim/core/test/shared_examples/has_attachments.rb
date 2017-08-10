# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has attachments" do
  context "when it has attachments", processing_uploads_for: Decidim::AttachmentUploader do
    let!(:document) { create(:attachment, :with_pdf, attached_to: attached_to) }

    let!(:image) { create(:attachment, attached_to: attached_to) }

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
end
