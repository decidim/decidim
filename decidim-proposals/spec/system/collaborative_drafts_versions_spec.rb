# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  include_context "with a component"
  let(:component) { create(:proposal_component, :with_creation_enabled, :with_collaborative_drafts_enabled, organization:) }

  let(:manifest_name) { "proposals" }
  let!(:author) { create :user, :confirmed, organization: }

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
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1 of 2")
      expect(page).to have_link("Version 2 of 2")
    end
  end

  context "when showing version" do
    before do
      click_link "see other versions"

      click_link("Version 2 of 2")
    end

    # REDESIGN_PENDING: The accessibility should be tested after complete redesign
    # it_behaves_like "accessible page"

    it "allows going back to the collaborative draft" do
      click_link "Back"
      expect(page).to have_current_path collaborative_draft_path
    end

    it "shows the version author and creation date" do
      skip_unless_redesign_enabled("this test pass using redesigned version_author cell")

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
      expect(page).to have_css(".versions_status", text: collaborative_draft.versions.count)
    end

    it "shows number of authors" do
      expect(page).to have_css(".authors_status", text: collaborative_draft.versions.group_by(&:whodunnit).size)
    end
  end
end
