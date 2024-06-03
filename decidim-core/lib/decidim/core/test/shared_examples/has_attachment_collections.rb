# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has attachment collections" do
  context "when it has attachment collections" do
    let(:attachment_collection) { create(:attachment_collection, collection_for:) }
    let!(:document) { create(:attachment, :with_pdf, attached_to:, attachment_collection:) }
    let!(:link) { create(:attachment, :with_link, attached_to:, attachment_collection:) }
    let!(:other_document) { create(:attachment, :with_pdf, attached_to:, attachment_collection: nil) }

    before do
      visit current_path
    end

    it "shows them" do
      expect(page).to have_content(translated(attachment_collection.name))
    end

    it "show their documents" do
      within "[id*=documents-#{attachment_collection.id}]", visible: false do
        expect(page).to have_content(:all, translated(document.title))
        expect(page).to have_content(:all, translated(link.title))
        expect(page).to have_no_content(:all, translated(other_document.title))
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_attachment_collection) { create(:attachment_collection, collection_for:, weight: 2) }
    let!(:document_one) { create(:attachment, :with_pdf, attached_to:, attachment_collection: last_attachment_collection) }

    let!(:first_attachment_collection) { create(:attachment_collection, collection_for:, weight: 1) }
    let!(:document_two) { create(:attachment, :with_pdf, attached_to:, attachment_collection: first_attachment_collection) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      expect(decidim_escape_translated(first_attachment_collection.name).gsub("&quot;",
                                                                              "\"")).to appear_before(decidim_escape_translated(last_attachment_collection.name).gsub("&quot;",
                                                                                                                                                                      "\""))
    end
  end

  context "when collection is empty" do
    let(:attachment_collection) { create(:attachment_collection, collection_for:) }
    let!(:document) { create(:attachment, :with_pdf, attached_to:, attachment_collection:) }
    let(:empty_attachment_collection) { create(:attachment_collection, collection_for:) }

    before do
      visit current_path
    end

    it "is not present" do
      expect(page).to have_content(translated(attachment_collection.name))
      expect(page).to have_no_content(translated(empty_attachment_collection.name))
    end
  end
end
