# frozen_string_literal: true

require "spec_helper"

describe "User votes suggestions" do
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
    <p>First paragraph</p>
    <p>Second paragraph</p>"
  end
  let!(:suggestion) do
    create(:collaborative_text_suggestion,
           document_version: document.current_version,
           changeset: {
             firstNode: "2",
             lastNode: "2",
             original: ["<p>First paragraph</p>"],
             replace: ["<p>A new content</p>"]
           })
  end

  context "when the user is not signed in" do
    before do
      visit_component
      click_on document.title
      click_on "1 suggestions"
    end

    it "shows the login modal" do
      find(".js-collaborative-texts-vote-up").click

      expect(page).to have_css("#loginModal", visible: :visible)
    end

    it "exposes the vote totals to screen readers" do
      up_count_id = "collaborative-texts-vote-up-count-#{suggestion.id}"
      down_count_id = "collaborative-texts-vote-down-count-#{suggestion.id}"

      within(".collaborative-texts-suggestions-box-item-votes") do
        expect(page).to have_css(".js-collaborative-texts-vote-up[aria-describedby='#{up_count_id}']")
        expect(page).to have_css(".js-collaborative-texts-vote-down[aria-describedby='#{down_count_id}']")
        expect(page).to have_css("##{up_count_id}", text: "0")
        expect(page).to have_css("##{down_count_id}", text: "0")
      end
    end
  end

  context "when the user is signed in" do
    let(:user) { create(:user, :confirmed, organization: component.organization) }

    before do
      login_as user, scope: :user
      visit_component
      click_on document.title
      click_on "1 suggestions"
    end

    it "upvotes and removes the vote" do
      within(".collaborative-texts-suggestions-box-item-votes") do
        find(".js-collaborative-texts-vote-up").click
        expect(page).to have_css(".js-collaborative-texts-vote-up-count", text: "1")
      end
      expect(suggestion.reload).to be_up_voted_by(user)

      within(".collaborative-texts-suggestions-box-item-votes") do
        find(".js-collaborative-texts-vote-up").click
        expect(page).to have_css(".js-collaborative-texts-vote-up-count", text: "0")
        expect(page).to have_css(".js-collaborative-texts-vote-down-count", text: "0")
      end
      expect(suggestion.reload).not_to be_up_voted_by(user)
    end

    it "replaces the vote when voting the other option" do
      within(".collaborative-texts-suggestions-box-item-votes") do
        find(".js-collaborative-texts-vote-up").click
        expect(page).to have_css(".js-collaborative-texts-vote-up-count", text: "1")

        find(".js-collaborative-texts-vote-down").click
        expect(page).to have_css(".js-collaborative-texts-vote-up-count", text: "0")
        expect(page).to have_css(".js-collaborative-texts-vote-down-count", text: "1")
      end

      expect(suggestion.reload).to be_down_voted_by(user)
      expect(suggestion).not_to be_up_voted_by(user)
    end

    it "keeps the vote after refreshing the page" do
      find(".js-collaborative-texts-vote-up").click
      expect(page).to have_css(".js-collaborative-texts-vote-up-count", text: "1")

      refresh
      click_on "1 suggestions"

      within(".collaborative-texts-suggestions-box-item-votes") do
        expect(page).to have_css(".js-collaborative-texts-vote-up.is-vote-selected")
        expect(page).to have_css(".js-collaborative-texts-vote-up-count", text: "1")
      end
    end
  end
end
