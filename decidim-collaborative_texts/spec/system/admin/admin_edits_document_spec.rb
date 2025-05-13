# frozen_string_literal: true

require "spec_helper"

describe "Admin edits documents" do
  let(:manifest_name) { "collaborative_texts" }
  let(:title) { "This is my document new title" }
  let(:body) { Faker::HTML.paragraph }
  let!(:document) { create(:collaborative_text_document, component:, title:, body:) }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:collaborative_text_component, participatory_space:) }
  end

  it "edits an existing document" do
    expect(document.accepting_suggestions?).to be false
    expect(page).to have_css(".action-icon--edit")
    click_on "Edit", match: :first
    expect(page).to have_content("Edit collaborative texts")

    fill_in "Title", with: "This is an edited title test"
    fill_in_editor :document_body, with: "body edited"
    check "Enable suggestions"
    click_on "Update"

    expect(page).to have_admin_callout "Document successfully updated"

    click_on "Manage"
    expect(page).to have_content("Configure collaborative texts")
    fill_in_i18n_editor(:document_announcement, "#document-announcement-tabs", { en: "New announcement" })

    click_on "Update"
    expect(page).to have_admin_callout "Document successfully updated"
    expect(page).to have_css(".table-list tbody tr", count: 1)

    expect(document.reload.title).to eq("This is an edited title test")
    expect(document.accepting_suggestions?).to be true
    expect(document.body).to eq("<p>body edited</p>")
    expect(document.announcement["en"]).to have_content("New announcement")
  end

  context "when title is invalid" do
    before do
      click_on "Edit", match: :first

      fill_in "Title", with: "this title is invalid"
      fill_in_editor :document_body, with: "a"
      click_on "Update"
    end

    it "displays an error message" do
      expect(page).to have_admin_callout "There was a problem updating the document"
      expect(page).to have_admin_callout "must start with a capital letter"
    end
  end

  context "when there are suggestions" do
    let!(:document) { create(:collaborative_text_document, component:, title:, body:, accepting_suggestions: true) }
    let!(:suggestion) { create(:collaborative_text_suggestion, document_version: document.current_version) }

    it "does not allow to edit the document the body" do
      click_on "Edit", match: :first
      expect(page).to have_content("Edit collaborative texts")

      fill_in "Title", with: "This is an edited title test"
      expect(page).to have_content("This document has suggestions and cannot be edited directly")
      fill_in_editor :document_body, with: "body edited"
      uncheck "Enable suggestions"
      click_on "Update"

      expect(page).to have_admin_callout "Document successfully updated"

      expect(document.reload.title).to eq("This is an edited title test")
      expect(document.accepting_suggestions?).to be false
      expect(document.draft?).to be false
      expect(document.body).not_to eq("<p>body edited</p>")
    end

    it "can discard suggestions by creating a new version" do
      expect(document.current_version.suggestions.count).to eq(1)
      click_on "Edit", match: :first
      expect(page).to have_content("Edit collaborative texts")

      check "Discard suggestions and create a new draft version"
      click_on "Update"

      expect(page).to have_admin_callout "Document successfully updated"

      expect(document.reload.document_versions.count).to eq(2)
      expect(document.current_version.suggestions.count).to eq(0)
      expect(document.draft?).to be true
      click_on "Edit", match: :first
      expect(page).to have_content("Version 1")
      expect(page).to have_content("Version 2")
      uncheck "Draft version"
      click_on "Update"
      expect(page).to have_admin_callout "Document successfully updated"
      expect(document.reload.document_versions.count).to eq(2)
      expect(document.draft?).to be false
    end
  end
end
