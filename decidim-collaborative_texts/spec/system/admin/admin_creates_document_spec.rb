# frozen_string_literal: true

require "spec_helper"

describe "Admin creates documents" do
  let(:manifest_name) { "collaborative_texts" }
  let(:title) { "This is my document new title" }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:collaborative_texts_component, participatory_space:) }
  end

  it "creates a new document" do
    click_on "New text"

    fill_in "Title", with: "This is an original title test"
    click_on "Create"

    expect(page).to have_admin_callout "Document successfully created"
    expect(page).to have_css(".table-list tbody tr", count: 1)
  end
end
