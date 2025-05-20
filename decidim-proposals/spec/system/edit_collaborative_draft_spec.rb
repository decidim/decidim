# frozen_string_literal: true

require "spec_helper"

describe "Edit collaborative_drafts" do
  include_context "with a component"
  let!(:component) { create(:proposal_component, :with_collaborative_drafts_enabled, organization:) }
  let(:manifest_name) { "proposals" }

  let!(:user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:another_user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:collaborative_draft) { create(:collaborative_draft, users: [user], component:) }

  before do
    switch_to_host user.organization.host
  end

  describe "editing my own collaborative draft" do
    let(:new_title) { "This is my collaborative_draft new title" }
    let(:new_body) { "This is my collaborative_draft new body" }

    before do
      login_as user, scope: :user
    end

    it "can be updated" do
      visit_component

      click_on "Access collaborative drafts"
      click_on collaborative_draft.title
      find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
      click_on "Edit"

      expect(page).to have_content "Edit collaborative draft"

      within "form.edit_collaborative_draft" do
        fill_in :collaborative_draft_title, with: new_title
        fill_in :collaborative_draft_body, with: new_body
        click_on "Send"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_body)
    end

    context "when attachment is enabled" do
      context "and after collaborative draft creation" do
        let!(:component) do
          create(:proposal_component,
                 :with_attachments_allowed_and_collaborative_drafts_enabled,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "can be updated" do
          visit_component

          click_on "Access collaborative drafts"
          click_on collaborative_draft.title
          find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
          click_on "Edit"

          dynamically_attach_file(:collaborative_draft_documents, Decidim::Dev.asset("city.jpeg"))

          within "form.edit_collaborative_draft" do
            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
        end
      end
    end

    context "when rich text editor is enabled" do
      before do
        organization.update(rich_text_editor_in_public_views: true)
        visit_component

        click_on "Access collaborative drafts"
        click_on collaborative_draft.title
        find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
        click_on "Edit"
      end

      it_behaves_like "having a rich text editor", "edit_collaborative_draft", "basic"
    end

    context "when updating with wrong data" do
      it "returns an error message" do
        visit_component

        click_on "Access collaborative drafts"
        click_on collaborative_draft.title
        find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
        click_on "Edit"

        within "form.edit_collaborative_draft" do
          fill_in :collaborative_draft_body, with: "A"
          click_on "Send"
        end

        # The character counters are doubled because there is a separate screen reader character counter.
        expect(page).to have_content("At least 15 characters", count: 4)

        within "form.edit_collaborative_draft" do
          fill_in :collaborative_draft_body, with: "WE DO NOT WANT TO SHOUT IN THE PROPOSAL BODY TEXT!"
          click_on "Send"
        end

        expect(page).to have_content("is using too many capital letters (over 25% of the text)")
      end

      it "keeps the submitted values" do
        visit_component

        click_on "Access collaborative drafts"
        click_on collaborative_draft.title
        find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
        click_on "Edit"

        within "form.edit_collaborative_draft" do
          fill_in :collaborative_draft_title, with: "A title with a title"
          fill_in :collaborative_draft_body, with: "ỲÓÜ WÄNTt TÙ ÚPDÀTÉ À PRÖPÔSÁL or a COLLABORATIVE DRAFT"
        end
        click_on "Send"

        expect(page).to have_css("input[value='A title with a title']")
        expect(page).to have_content("ỲÓÜ WÄNTt TÙ ÚPDÀTÉ À PRÖPÔSÁL")
      end
    end
  end

  describe "editing someone else's proposal" do
    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_on "Access collaborative drafts"
      click_on collaborative_draft.title
      expect(page).to have_no_content("Edit collaborative draft")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end

  describe "editing my proposal outside the time limit" do
    let!(:collaborative_draft) { create(:collaborative_draft, users: [user], component:, created_at: 1.hour.ago) }

    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_on "Access collaborative drafts"
      click_on collaborative_draft.title
      expect(page).to have_no_content("Edit collaborative draft")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
