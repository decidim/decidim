# frozen_string_literal: true

require "spec_helper"

describe "Valuator manages proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let!(:assigned_proposal) { create :proposal, component: current_component }
  let!(:unassigned_proposal) { create :proposal, component: current_component }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let!(:user) { create :user, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: user, participatory_process: participatory_process }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  before do
    create :valuation_assignment, proposal: assigned_proposal, valuator_role: valuator_role

    visit current_path
  end

  context "when listing the proposals" do
    it "can only see the assigned proposals" do
      expect(page).to have_content(assigned_proposal.title)
      expect(page).to have_no_content(unassigned_proposal.title)
    end
  end
end
