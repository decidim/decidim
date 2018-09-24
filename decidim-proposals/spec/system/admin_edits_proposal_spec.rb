# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:proposal) { create :proposal, :official, component: component }
  let(:creation_enabled?) { true }

  include_context "when managing a component as an admin"

  before do
    component.update!(
      step_settings: {
        component.participatory_space.active_step.id => {
          creation_enabled: creation_enabled?
        }
      }
    )
  end

  describe "editing an official proposal" do
    let(:new_title) { "This is my proposal new title" }
    let(:new_body) { "This is my proposal new body" }

    it "can be updated" do
      visit_component_admin

      find("a.action-icon--edit-proposal").click
      expect(page).to have_content "UPDATE PROPOSAL"

      fill_in "Title", with: new_title
      fill_in "Body", with: new_body
      click_button "Update"

      preview_window = window_opened_by { find("a.action-icon--preview").click }

      within_window preview_window do
        expect(page).to have_content(new_title)
        expect(page).to have_content(new_body)
      end
    end

    context "when updating with wrong data" do
      let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed, participatory_space: participatory_process) }

      it "returns an error message" do
        visit_component_admin

        find("a.action-icon--edit-proposal").click
        expect(page).to have_content "UPDATE PROPOSAL"

        fill_in "Body", with: "A"
        click_button "Update"

        expect(page).to have_content("is using too many capital letters (over 25% of the text), is too short (under 15 characters)")
      end
    end
  end

  describe "editing a non-official proposal" do
    let!(:proposal) { create :proposal, users: [user], component: component }

    it "renders an error" do
      visit_component_admin

      expect(page).to have_content(proposal.title)
      expect(page).to have_no_css("a.action-icon--edit-proposal")
      visit current_path + "proposals/#{proposal.id}/edit"

      expect(page).to have_content("not authorized")
    end
  end

  describe "editing my proposal outside the time limit" do
    let!(:proposal) { create :proposal, :official, component: component, updated_at: 1.hour.ago }

    it "renders an error" do
      visit_component_admin

      expect(page).to have_text(proposal.title)
      expect(page).to have_no_css("a.action-icon--edit-proposal")
      visit current_path + "proposals/#{proposal.id}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
