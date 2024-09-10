# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectHistoryCell, type: :cell do
    controller Decidim::Budgets::ProjectsController
    let!(:project) { create(:project) }
    let(:participatory_space) { project.participatory_space }
    let(:component) { create(:budget_component) }
    let(:organization) { project.organization }
    let(:user) { create(:user, organization: project.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when the project budget has linked resources" do
      context "when a project budget has been linked in a proposal" do
        let(:proposal_component) do
          create(:component, manifest_name: :proposals, participatory_space: project.component.participatory_space)
        end
        let(:proposal) { create(:proposal, component: proposal_component) }

        before do
          proposal.link_resources([project], "included_proposals")
        end

        it "shows related results" do
          html = cell("decidim/budgets/project_history", project).call
          expect(html).to have_content("The proposal")
          expect(html).to have_content("was created")
        end
      end
    end
  end
end
