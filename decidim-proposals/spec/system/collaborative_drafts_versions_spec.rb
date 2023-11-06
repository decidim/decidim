# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", type: :system, versioning: true do
  include_context "with a component"
  let(:component) { create(:proposal_component, :with_creation_enabled, :with_collaborative_drafts_enabled, organization:) }

  let(:manifest_name) { "proposals" }
  let!(:author) { create(:user, :confirmed, organization:) }

  let(:collaborative_draft_path) do
    Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
  end
  let(:original_title) { "The original title" }
  let(:edited_title) { "The edited title" }
  let(:original_body) { "Original body, consequuntur cupiditate non reprehenderit est vero fugiat" }
  let(:edited_body) { "Edited body, Rerum assumenda blanditiis voluptatum autem, praesentium necessitatibus est" }
  let!(:collaborative_draft) { create(:collaborative_draft, component:, title: original_title, body: original_body) }

  before do
    Decidim.traceability.update!(
      collaborative_draft,
      author,
      title: edited_title,
      body: edited_body
    )
    visit collaborative_draft_path
  end

  context "when visiting versions index" do
    before do
      click_link "see other versions", match: :first
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1 of 2")
      expect(page).to have_link("Version 2 of 2")
    end
  end

  context "when showing version" do
    before do
      click_link "see other versions", match: :first

      click_link("Version 2 of 2")
    end

    it_behaves_like "accessible page"

    it "shows the version author and creation date" do
      within ".version__author" do
        expect(page).to have_content(author.name)
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within "#diff-for-title" do
        expect(page).to have_content("Title")

        within ".diff > ul > .del" do
          expect(page).to have_content(original_title)
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content(edited_title)
        end
      end

      within "#diff-for-body" do
        expect(page).to have_content("Body")

        within ".diff > ul > .del" do
          expect(page).to have_content(original_body)
        end

        within ".diff > ul > .ins" do
          expect(page).to have_content(edited_body)
        end
      end
    end
  end

  context "when visiting the collaborative draft details" do
    before do
      Decidim.traceability.update!(
        collaborative_draft,
        author,
        title: "Edited title another time"
      )
      visit collaborative_draft_path
    end

    it "shows number of versions" do
      expect(page).to have_content("(of #{collaborative_draft.versions.count})")
    end
  end
end
