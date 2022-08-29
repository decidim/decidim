# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: }
  let!(:proposal) { create :proposal, :official, component: }
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
      expect(page).to have_content "Update proposal"

      fill_in_i18n :proposal_title, "#proposal-title-tabs", en: new_title
      fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: new_body
      click_button "Update"

      preview_window = window_opened_by { find("a.action-icon--preview").click }

      within_window preview_window do
        expect(page).to have_content(new_title)
        expect(page).to have_content(new_body)
      end
    end

    context "when the proposal has some votes" do
      before do
        create :proposal_vote, proposal:
      end

      it "doesn't let the user edit it" do
        visit_component_admin

        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_no_css("a.action-icon--edit-proposal")
        visit current_path + "proposals/#{proposal.id}/edit"

        expect(page).to have_content("not authorized")
      end
    end

    context "when the proposal has attachement" do
      let!(:component) do
        create(:proposal_component,
               :with_creation_enabled,
               :with_attachments_allowed,
               manifest:,
               participatory_space: participatory_process)
      end

      let!(:proposal) do
        create(:proposal,
               :official,
               component:,
               title: "Proposal with attachments",
               body: "This is my proposal and I want to upload attachments.")
      end

      let!(:document) { create(:attachment, :with_pdf, attached_to: proposal) }

      it "can be remove attachment" do
        visit_component_admin
        find("a.action-icon--edit-proposal").click
        find("input#proposal_attachment_delete_file").set(true)
        find(".form-general-submit .button").click

        expect(page).to have_content("Proposal successfully updated.")

        visit_component_admin
        find("a.action-icon--edit-proposal").click
        expect(page).to have_no_content("Current file")
      end
    end
  end

  describe "editing a non-official proposal" do
    let!(:proposal) { create :proposal, users: [user], component: }

    it "renders an error" do
      visit_component_admin

      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_no_css("a.action-icon--edit-proposal")
      visit current_path + "proposals/#{proposal.id}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
