# frozen_string_literal: true

require "spec_helper"

describe "Edit proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:another_user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:proposal) { create :proposal, users: [user], component: component }
  let!(:proposal_title) { translated(proposal.title) }

  before do
    switch_to_host user.organization.host
  end

  describe "editing my own proposal" do
    let(:new_title) { "This is my proposal new title" }
    let(:new_body) { "This is my proposal new body" }

    before do
      login_as user, scope: :user
    end

    it "can be updated" do
      visit_component

      click_link proposal_title
      click_link "Edit proposal"

      expect(page).to have_content "EDIT PROPOSAL"

      within "form.edit_proposal" do
        fill_in :proposal_title, with: new_title
        fill_in :proposal_body, with: new_body
        click_button "Send"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_body)
    end

    context "when updating with wrong data" do
      let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed, participatory_space: participatory_process) }

      it "returns an error message" do
        visit_component

        click_link proposal_title
        click_link "Edit proposal"

        expect(page).to have_content "EDIT PROPOSAL"

        within "form.edit_proposal" do
          fill_in :proposal_body, with: "A"
          click_button "Send"
        end

        expect(page).to have_content("at least 15 characters", count: 2)

        within "form.edit_proposal" do
          fill_in :proposal_body, with: "WE DO NOT WANT TO SHOUT IN THE PROPOSAL BODY TEXT!"
          click_button "Send"
        end

        expect(page).to have_content("is using too many capital letters (over 25% of the text)")
      end

      it "keeps the submitted values" do
        visit_component

        click_link proposal_title
        click_link "Edit proposal"

        expect(page).to have_content "EDIT PROPOSAL"

        within "form.edit_proposal" do
          fill_in :proposal_title, with: "A title with a #hashtag"
          fill_in :proposal_body, with: "ỲÓÜ WÄNTt TÙ ÚPDÀTÉ À PRÖPÔSÁL"
        end
        click_button "Send"

        expect(page).to have_selector("input[value='A title with a #hashtag']")
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

      click_link proposal_title
      expect(page).to have_no_content("Edit proposal")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end

  describe "editing my proposal outside the time limit" do
    let!(:proposal) { create :proposal, users: [user], component: component, created_at: 1.hour.ago }

    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_link proposal_title
      expect(page).to have_no_content("Edit proposal")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
