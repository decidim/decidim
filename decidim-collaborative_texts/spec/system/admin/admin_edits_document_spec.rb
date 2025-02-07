# frozen_string_literal: true

require "spec_helper"

describe "Admin edits documents" do
  let(:manifest_name) { "collaborative_texts" }
  let(:title) { "This is my document new title" }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:collaborative_texts_component, participatory_space:) }
  end

  before do
    click_on "New text"
    fill_in "Title", with: "This is an original title test"
    click_on "Create"
  end

  it "edits an existing document" do
    click_on "Edit", match: :first
    expect(page).to have_content("Edit Collaborative Texts")

    fill_in "Title", with: "This is an edited title test"
    click_on "Update"

    expect(page).to have_admin_callout "Document successfully updated"

    click_on "Manage"
    expect(page).to have_content("Configure Collaborative Texts")
    check "Allow participants to make suggestions"

    click_on "Update"
    expect(page).to have_admin_callout "Document successfully updated"
    expect(page).to have_css(".table-list tbody tr", count: 1)
  end
end
