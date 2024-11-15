# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalHistoryCell, type: :cell do
    controller Decidim::Proposals::ProposalsController
    let!(:proposal) { create(:proposal) }
    let(:participatory_space) { proposal.participatory_space }
    let(:component) { create(:proposal_component) }
    let(:organization) { proposal.organization }
    let(:user) { create(:user, organization: proposal.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when the proposal has linked resources" do
      context "when proposal has been linked in a budget" do
        let(:budget_component) do
          create(:component, manifest_name: :budgets, participatory_space: proposal.component.participatory_space)
        end
        let(:project) { create(:project, component: budget_component) }

        before do
          project.link_resources([proposal], "included_proposals")
        end

        it "shows related projects" do
          html = cell("decidim/proposals/proposal_history", proposal).call
          expect(html).to have_content("It was added to this budget:")
        end
      end

      context "when a proposal has been linked in a result" do
        let(:accountability_component) do
          create(:component, manifest_name: :accountability, participatory_space: proposal.component.participatory_space)
        end
        let(:result) { create(:result, component: accountability_component) }

        before do
          result.link_resources([proposal], "included_proposals")
        end

        it "shows related resources" do
          html = cell("decidim/proposals/proposal_history", proposal).call
          expect(html).to have_content("It was added to this result:")
        end
      end

      context "when a proposal has been linked in a meeting" do
        let(:meeting_component) do
          create(:component, manifest_name: :meetings, participatory_space: proposal.component.participatory_space)
        end
        let(:meeting) { create(:meeting, :published, component: meeting_component) }

        before do
          meeting.link_resources([proposal], "proposals_from_meeting")
        end

        it "shows related meetings" do
          html = cell("decidim/proposals/proposal_history", proposal).call
          expect(html).to have_content("It was discussed in this meeting:")
        end
      end
    end
  end
end
