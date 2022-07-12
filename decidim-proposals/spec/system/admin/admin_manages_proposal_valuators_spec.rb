# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals valuators", type: :system do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, component: current_component }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let!(:valuator) { create :user, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  context "when assigning to a valuator" do
    before do
      visit current_path

      within find("tr", text: translated(proposal.title)) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_button "Actions"
      click_button "Assign to valuator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-assign-proposals-to-valuator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_css("button#js-submit-assign-proposals-to-valuator", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-assign-proposals-to-valuator" do
          select valuator.name, from: :valuator_role_id
          page.find("button#js-submit-assign-proposals-to-valuator").click
        end
      end

      it "assigns the proposals to the valuator" do
        expect(page).to have_content("Proposals assigned to a valuator successfully")

        within find("tr", text: translated(proposal.title)) do
          expect(page).to have_selector("td.valuators-count", text: 1)
        end
      end
    end
  end

  context "when filtering proposals by assigned valuator" do
    let!(:unassigned_proposal) { create :proposal, component: component }
    let(:assigned_proposal) { proposal }

    before do
      create :valuation_assignment, proposal: proposal, valuator_role: valuator_role

      visit current_path
    end

    it "only shows the proposals assigned to the selected valuator" do
      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_content(translated(unassigned_proposal.title))

      within ".filters__section" do
        find("a.dropdown", text: "Filter").hover
        find("a", text: "Assigned to valuator").hover
        find("a", text: valuator.name).click
      end

      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_no_content(translated(unassigned_proposal.title))
    end
  end

  context "when unassigning valuators from a proposal from the proposals index page" do
    let(:assigned_proposal) { proposal }

    before do
      create :valuation_assignment, proposal: proposal, valuator_role: valuator_role

      visit current_path

      within find("tr", text: translated(proposal.title)) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_button "Actions"
      click_button "Unassign from valuator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-unassign-proposals-from-valuator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_css("button#js-submit-unassign-proposals-from-valuator", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-unassign-proposals-from-valuator" do
          select valuator.name, from: :valuator_role_id
          page.find("button#js-submit-unassign-proposals-from-valuator").click
        end
      end

      it "unassigns the proposals to the valuator" do
        expect(page).to have_content("Valuator unassigned from proposals successfully")

        within find("tr", text: translated(proposal.title)) do
          expect(page).to have_selector("td.valuators-count", text: 0)
        end
      end
    end
  end

  context "when unassigning valuators from a proposal from the proposal show page" do
    let(:assigned_proposal) { proposal }

    before do
      create :valuation_assignment, proposal: proposal, valuator_role: valuator_role

      visit current_path
      within find("tr", text: translated(proposal.title)) do
        click_link "Valuate"
      end
    end

    it "can unassign a valuator" do
      within "#valuators" do
        expect(page).to have_content(valuator.name)

        accept_confirm do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Valuator unassigned from proposals successfully")

      expect(page).to have_no_selector("#valuators")
    end
  end
end
