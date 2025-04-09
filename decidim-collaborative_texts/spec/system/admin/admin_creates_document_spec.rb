# frozen_string_literal: true

require "spec_helper"

describe "Admin creates documents" do
  let(:manifest_name) { "collaborative_texts" }
  let(:title) { "This is my document new title" }
  let(:body) { Faker::HTML.paragraph }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:collaborative_text_component, participatory_space:) }
  end

  it "creates a new document" do
    click_on "New text"

    fill_in "Title", with: title
    fill_in_editor :document_body, with: body
    click_on "Create"

    expect(page).to have_admin_callout "Document successfully created"
    expect(page).to have_css(".table-list tbody tr", count: 1)
  end

  context "when title is invalid" do
    before do
      click_on "New text"

      fill_in "Title", with: "this title is invalid"
      click_on "Create"
    end

    it "displays an error message" do
      expect(page).to have_admin_callout "There was a problem creating the document"
      expect(page).to have_admin_callout "must start with a capital letter"
    end
  end
end
