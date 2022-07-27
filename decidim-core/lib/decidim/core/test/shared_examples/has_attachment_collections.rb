# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has attachment collections" do
  context "when it has attachment collections" do
    let(:attachment_collection) { create(:attachment_collection, collection_for:) }
    let!(:document) { create(:attachment, :with_pdf, attached_to:, attachment_collection:) }
    let!(:other_document) { create(:attachment, :with_pdf, attached_to:, attachment_collection: nil) }

    before do
      visit current_path
    end

    it "shows them" do
      within ".attachments .documents" do
        expect(page).to have_content(/#{translated(attachment_collection.name, locale: :en)}/i)
      end
    end

    it "show their documents" do
      within ".attachments .documents #docs-collection-#{attachment_collection.id}", visible: false do
        expect(page).to have_content(:all, /#{translated(document.title, locale: :en)}/i)
        expect(page).not_to have_content(:all, /#{translated(other_document.title, locale: :en)}/i)
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
      within ".attachments .documents" do
        expect(translated(first_attachment_collection.name, locale: :en)).to appear_before(translated(last_attachment_collection.name, locale: :en))
      end
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
      within ".attachments .documents" do
        expect(page).to have_content(/#{translated(attachment_collection.name, locale: :en)}/i)
        expect(page).not_to have_content(/#{translated(empty_attachment_collection.name, locale: :en)}/i)
      end
    end
  end
end
