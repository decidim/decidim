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
    fill_in "Title", with: title
    click_on "Create"
  end

  it "publishes and unpublish a document" do
    expect(page).to have_content("Collaborative texts")
    expect(page).to have_content("New text")
    expect(page).to have_content("Configure")

    expect(page).to have_css(".action-icon--publish")
    click_on "Publish", match: :first
    expect(page).to have_admin_callout "Document successfully published"

    expect(page).to have_css(".action-icon--unpublish")
    click_on "Unpublish", match: :first
    expect(page).to have_admin_callout "Document successfully unpublished"
  end
end
