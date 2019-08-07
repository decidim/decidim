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

    context "when the proposal has some votes" do
      before do
        create :proposal_vote, proposal: proposal
      end

      it "doesn't let the user edit it" do
        visit_component_admin

        expect(page).to have_content(proposal.title)
        expect(page).to have_no_css("a.action-icon--edit-proposal")
        visit current_path + "proposals/#{proposal.id}/edit"

        expect(page).to have_content("not authorized")
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
end
