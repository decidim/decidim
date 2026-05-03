# frozen_string_literal: true

require "spec_helper"

describe "User adds suggestions" do
  include Decidim::FrontEndPointerTestHelpers

  include_context "with a component"
  let(:manifest_name) { "collaborative_texts" }
  let!(:component) do
    create(:collaborative_text_component,
           manifest:,
           participatory_space: participatory_process)
  end

  context "with no documents" do
    it "shows an empty page with a message" do
      visit_component

      expect(page).to have_content("There are no collaborative texts yet")
    end
  end

  context "with documents" do
    let!(:unpublished_document) { create(:collaborative_text_document, component:) }
    let!(:document) { create(:collaborative_text_document, :published, component:, body:) }
    let(:body) do
      "<h2>First title</h2>
      <p>First <b>paragraph</b></p>
      <p>Second paragraph</p>
      <h2>Second title</h2>
      <p>Third paragraph</p>"
    end
    let!(:suggestion) { create(:collaborative_text_suggestion, changeset:, document_version: document.current_version) }
    let(:changeset) do
      {
        firstNode: "2",
        lastNode: "2",
        original: ["<p>First paragraph</p>"],
        replace: ["<p>A new content</p>"]
      }
    end

    before do
      visit_component
    end

    it "lists all the documents" do
      within("aside") do
        expect(page).to have_content(translated(component.name))
      end

      expect(page).to have_content(document.title)
      expect(page).to have_no_content(unpublished_document.title)
    end

    it "shows the document details" do
      click_on document.title

      expect(page).to have_content(translated(document.title))
      within("aside") do
        expect(page).to have_content("Index")
        expect(page).to have_content("First title")
        expect(page).to have_no_content("First paragraph")
        expect(page).to have_content("Second title")
        expect(page).to have_no_content("Second paragraph")
      end
      expect(page).to have_content("Suggestions are not allowed at this time")
      within ".collaborative-texts-container" do
        expect(page).to have_css("h2", id: "ct-node-1", text: "First title")
        expect(page).to have_css("p", id: "ct-node-2", text: "First paragraph")
        expect(page).to have_css("p", id: "ct-node-3", text: "Second paragraph")
        expect(page).to have_css("h2", id: "ct-node-4", text: "Second title")
        expect(page).to have_css("p", id: "ct-node-5", text: "Third paragraph")
        expect(page).to have_css(".collaborative-texts-suggestions-box", count: 1)
        within(".collaborative-texts-suggestions-box") do
          expect(page).to have_content("1 suggestions")
          click_on "1 suggestions"
          expect(page).to have_content("Replace: A new content")
        end
        expect(page).to have_content("A new content", count: 1)
        expect(page).to have_content("First paragraph")
        find(".collaborative-texts-suggestions-box-item").hover
      end

      expect(page).to have_content("A new content", count: 2)
      expect(page).to have_no_content("First paragraph")

      find("aside").click # to force a "blur" event
      expect(page).to have_content("A new content", count: 1)
      expect(page).to have_content("First paragraph")
    end

    context "when suggestions are enabled" do
      let!(:document) { create(:collaborative_text_document, :published, accepting_suggestions: true, component:, body:) }

      it "shows the login modal" do
        click_on document.title

        expect(page).to have_content("To suggest changes, select or double-click")

        select_text("#ct-node-3")
        expect(page).to have_button("Suggest changes", disabled: true)
        within(".collaborative-texts-editor-container") do
          expect(page).to have_content("Second paragraph")
        end
        select_text("#ct-node-2 b")
        expect(page).to have_no_content("A selection is active")
        expect(page).to have_button("Suggest changes", disabled: true)
        within(".collaborative-texts-editor-container") do
          expect(page).to have_content("First paragraph")
        end
        find(".collaborative-texts-editor-container").send_keys("Edited ")
        select_text("#ct-node-3")
        expect(page).to have_content("A selection is active")
        within(".collaborative-texts-editor-container") do
          expect(page).to have_content("Edited First paragraph")
        end

        click_on "Suggest changes"
        expect(page).to have_content("Please log in")
      end

      context "and user is logged in" do
        let(:user) { create(:user, :confirmed, organization: component.organization) }

        before do
          login_as user, scope: :user
          visit_component
          sleep 0.1
        end

        it "allows to create suggestions" do
          click_on document.title

          select_text("#ct-node-2 b")
          find(".collaborative-texts-editor-container").send_keys("Edited ")

          click_on "Suggest changes"
          expect(page).to have_content("2 suggestions")
          expect(page).to have_content("First paragraph", count: 1)

          click_on "2 suggestions"
          expect(page).to have_content("First paragraph", count: 2)
          expect(page).to have_content("Edited First paragraph", count: 1)
          expect(page).to have_content("A new content", count: 1)
          find(".collaborative-texts-suggestions-box-item:first-child").hover
          expect(page).to have_content("First paragraph", count: 1)
          expect(page).to have_content("A new content", count: 2)
        end
      end
    end
  end
end
