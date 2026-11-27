# frozen_string_literal: true

require "spec_helper"

describe "User comments on suggestions", js: true do
  include_context "with a component"
  let(:manifest_name) { "collaborative_texts" }
  let!(:component) do
    create(:collaborative_text_component,
           manifest:,
           participatory_space: participatory_process)
  end
  let!(:document) do
    create(:collaborative_text_document, :published, component:, body: "<p>First paragraph</p>")
  end
  let!(:suggestion) do
    create(
      :collaborative_text_suggestion,
      document_version: document.current_version,
      changeset: {
        firstNode: "1",
        lastNode: "1",
        original: ["<p>First paragraph</p>"],
        replace: ["<p>Replacement</p>"]
      }
    )
  end
  let(:user) { create(:user, :confirmed, organization: component.organization) }

  before do
    login_as user, scope: :user
    visit_component
    click_on document.title
    click_on "1 suggestions"
  end

  it "adds a comment and keeps it after a refresh" do
    click_on "Comment"
    fill_in "add-comment-Suggestion-#{suggestion.id}", with: "My comment"
    click_on "Publish comment"
    expect(page).to have_text("My comment")

    visit current_path
    click_on "1 suggestions"
    click_on "Comment"
    expect(page).to have_text("My comment")
  end
end
