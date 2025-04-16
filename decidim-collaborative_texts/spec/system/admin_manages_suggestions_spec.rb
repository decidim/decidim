# frozen_string_literal: true

require "spec_helper"

describe "Admin edits documents" do
  include_context "with a component"
  let(:manifest_name) { "collaborative_texts" }
  let!(:component) do
    create(:collaborative_text_component,
           manifest:,
           participatory_space: participatory_process)
  end
  let!(:document) { create(:collaborative_text_document, :published, component:, body:) }
  let(:body) do
    "<h2>First title</h2>
    <p>First <b>paragraph</b></p>
    <p>Second paragraph</p>
    <h2>Second title</h2>
    <p>Third paragraph</p>"
  end

  let!(:suggestion1) { create(:collaborative_text_suggestion, changeset: changeset1, document_version: document.current_version) }
  let(:changeset1) do
    {
      firstNode: "5",
      lastNode: "5",
      original: ["<p>Third paragraph</p>"],
      replace: ["<p>A new content</p>"]
    }
  end
  let!(:suggestion2) { create(:collaborative_text_suggestion, changeset: changeset2, document_version: document.current_version) }
  let(:changeset2) do
    {
      firstNode: "4",
      lastNode: "5",
      original: ["<h2>Second title</h2>", "<p>Third paragraph</p>"],
      replace: ["<p>A meaningful content</p>"]
    }
  end
  let!(:suggestion3) { create(:collaborative_text_suggestion, changeset: changeset3, document_version: document.current_version) }
  let(:changeset3) do
    {
      firstNode: "5",
      lastNode: "5",
      original: [""],
      replace: ["<p>Third paragraph</p>", "<p>Added content</p>"]
    }
  end
  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

  before do
    login_as user, scope: :user
    visit_component
    click_on document.title
  end

  it "can apply a suggestion" do
    expect(page).to have_content(translated(document.title))

    expect(page).to have_content("1 suggestions")
    expect(page).to have_content("2 suggestions")
    expect(page).to have_content("First title", count: 2) # TOC & content
    expect(page).to have_content("Second title", count: 2)
    expect(page).to have_content("Third paragraph")
    expect(page).to have_no_content("A new content")
    expect(page).to have_no_content("Added content")
    expect(page).to have_no_content("A meaningful content")

    click_on "2 suggestions"
    click_on "Suggestion controls", match: :first
    click_on "Apply"
    expect(page).to have_no_content("Third paragraph")
    expect(page).to have_content("A new content")

    click_on "2 suggestions"
    within ".collaborative-texts-suggestions-box-item:last-child" do
      click_on "Suggestion controls"
    end
    click_on "Apply"
    expect(page).to have_content("Third paragraph")
    expect(page).to have_no_content("A new content")
    expect(page).to have_content("Added content")

    click_on "1 suggestions"
    # page.execute_script('document.querySelector(".collaborative-texts-suggestions-box-item:first-child [data-component=dropdown]").click()')
    click_on "Suggestion controls"
    click_on "Apply"
    expect(page).to have_no_content("Second title")
    expect(page).to have_no_content("A new content")
    expect(page).to have_no_content("Added content")
    expect(page).to have_content("A meaningful content")

    click_on "2 suggestions"
    all(".collaborative-texts-suggestions-box-item-dropdown").first.hover
    expect(page).to have_no_content("A meaningful content")
    expect(page).to have_content("Second title", count: 1) # TOC is not rendered on hover
    expect(page).to have_content("A new content")

    within ".collaborative-texts-manager" do
      click_on "Cancel"
    end

    expect(page).to have_no_button("Cancel")
    expect(page).to have_no_button("Draft a new version")
    expect(page).to have_no_button("Consolidate accepted versions")
    expect(page).to have_content("First title", count: 2)
    expect(page).to have_content("Second title", count: 2)
    expect(page).to have_content("Third paragraph")
    expect(page).to have_no_content("A new content")
    expect(page).to have_no_content("Added content")
    expect(page).to have_no_content("A meaningful content")
  end

  # TODO: restore
  # todo draft
  # todo cancel
  # todo consolidate
end
