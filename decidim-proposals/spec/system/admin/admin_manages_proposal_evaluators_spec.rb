# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals evaluators" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: current_component) }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let!(:evaluator) { create(:user, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
  let!(:other_evaluator) { create(:user, organization:) }
  let!(:other_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: other_evaluator, participatory_process:) }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  context "when assigning to a evaluator" do
    before do
      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to evaluator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-assign-proposals-to-evaluator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_button(id: "js-submit-assign-proposals-to-evaluator", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-assign-proposals-to-evaluator" do
          tom_select("#assign_evaluator_role_ids", option_id: evaluator_role.id)
          click_on(id: "js-submit-assign-proposals-to-evaluator")
        end
      end

      it "assigns the proposals to the evaluator" do
        expect(page).to have_content("Proposals assigned to a evaluator successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.evaluators-count", text: 1)
        end
      end

      it "displays log" do
        visit decidim_admin.root_path
        expect(page).to have_content("assigned the #{translated(proposal.title)} proposal to a evaluator")
      end
    end
  end

  context "when assigning to multiple evaluators" do
    before do
      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to evaluator"
    end

    context "when submitting the form" do
      before do
        within "#js-form-assign-proposals-to-evaluator" do
          tom_select("#assign_evaluator_role_ids", option_id: [evaluator_role.id, other_evaluator_role.id])
          click_on(id: "js-submit-assign-proposals-to-evaluator")
        end
      end

      it "assigns the proposals to the evaluator" do
        expect(page).to have_content("Proposals assigned to a evaluator successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.evaluators-count", text: 2)
        end
      end
    end
  end

  context "when filtering proposals by assigned evaluator" do
    let!(:unassigned_proposal) { create(:proposal, component:) }
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)

      visit current_path
    end

    it "only shows the proposals assigned to the selected evaluator" do
      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_content(translated(unassigned_proposal.title))

      within ".filters__section" do
        find("a.dropdown", text: "Filter").hover
        find("a", text: "Assigned to evaluator").hover
        find("a", text: evaluator.name).click
      end

      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_no_content(translated(unassigned_proposal.title))
    end
  end

  context "when unassigning evaluators from a proposal from the proposals index page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)

      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Unassign from evaluator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-unassign-proposals-from-evaluator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_button(id: "js-submit-unassign-proposals-from-evaluator", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-unassign-proposals-from-evaluator" do
          tom_select("#unassign_evaluator_role_ids", option_id: evaluator_role.id)
          click_on(id: "js-submit-unassign-proposals-from-evaluator")
        end
      end

      it "unassigns the proposals from the evaluator" do
        expect(page).to have_content("Evaluator unassigned from proposals successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.evaluators-count", text: 0)
        end
      end
    end
  end

  context "when unassigning multiple evaluators from a proposal from the proposals index page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)
      create(:evaluation_assignment, proposal:, evaluator_role: other_evaluator_role)

      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Unassign from evaluator"
    end

    context "when submitting the form" do
      before do
        within "#js-form-unassign-proposals-from-evaluator" do
          tom_select("#unassign_evaluator_role_ids", option_id: [evaluator_role.id, other_evaluator_role.id])
          click_on(id: "js-submit-unassign-proposals-from-evaluator")
        end
      end

      it "unassigns the proposals from the evaluator" do
        expect(page).to have_content("Evaluator unassigned from proposals successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.evaluators-count", text: 0)
        end
      end
    end
  end

  context "when unassigning evaluators from a proposal from the proposal show page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)

      visit current_path
      within "tr", text: translated(proposal.title) do
        click_on "Answer proposal"
      end
    end

    it "can unassign a evaluator" do
      within "#evaluators" do
        expect(page).to have_content(evaluator.name)

        accept_confirm do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Evaluator unassigned from proposals successfully")

      expect(page).to have_no_selector("#evaluators")
    end
  end
end
