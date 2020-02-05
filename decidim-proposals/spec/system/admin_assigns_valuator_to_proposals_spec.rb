# frozen_string_literal: true

require "spec_helper"

describe "Admin assigns valuator to proposal", type: :system do
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

  before do
    visit current_path
  end

  context "when assigning to a valuator from the actions dropdown" do
    before do
      within find("tr", text: proposal.title) do
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

        within find("tr", text: proposal.title) do
          expect(page).to have_selector("td.valuators-count", text: 1)
        end
      end
    end
  end
end
