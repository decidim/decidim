# frozen_string_literal: true

require "spec_helper"

describe "Admin edits documents" do
  let(:manifest_name) { "collaborative_texts" }
  let(:title) { "This is my document new title" }
  let(:body) { Faker::HTML.paragraph }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:collaborative_texts_component, participatory_space:) }
  end

  before do
    click_on "New text"
    fill_in "Title", with: title
    fill_in_editor :document_body, with: body
    click_on "Create"
  end

  it "edits an existing document" do
    expect(page).to have_css(".action-icon--edit")
    click_on "Edit", match: :first
    expect(page).to have_content("Edit collaborative texts")

    fill_in "Title", with: "This is an edited title test"
    click_on "Update"

    expect(page).to have_admin_callout "Document successfully updated"

    click_on "Manage"
    expect(page).to have_content("Configure collaborative texts")
    check "Allow participants to make suggestions"

    click_on "Update"
    expect(page).to have_admin_callout "Document successfully updated"
    expect(page).to have_css(".table-list tbody tr", count: 1)
  end

  context "when title is invalid" do
    before do
      click_on "Edit", match: :first

      fill_in "Title", with: "this title is invalid"
      click_on "Update"
    end

    it "displays an error message" do
      expect(page).to have_admin_callout "There was a problem updating the document"
      expect(page).to have_admin_callout "must start with a capital letter"
    end
  end
end
