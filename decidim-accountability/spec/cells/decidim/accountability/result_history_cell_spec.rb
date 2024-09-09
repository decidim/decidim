# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultHistoryCell, type: :cell do
    controller Decidim::Accountability::ResultsController

    let!(:result) { create(:result) }
    let(:participatory_space) { result.participatory_space }
    let(:component) { create(:accountability_component) }
    let(:organization) { result.organization }
    let(:user) { create(:user, organization: result.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when the result has linked resources" do
      context "when result has been linked in a proposal" do
        let(:proposal_component) do
          create(:component, manifest_name: :proposals, participatory_space: result.component.participatory_space)
        end
        let(:proposal) { create(:proposal, component: proposal_component) }

        before do
          proposal.link_resources([result], "included_proposals")
        end

        it "shows related proposals" do
          html = cell("decidim/accountability/result_history", result).call
          expect(html).to have_content("It was included in this proposal:")
        end
      end

      context "when a result has been linked in a project" do
        let(:budget_component) do
          create(:component, manifest_name: :budgets, participatory_space: result.component.participatory_space)
        end
        let(:project) { create(:project, component: budget_component) }

        before do
          project.link_resources([result], "included_projects")
        end

        it "shows related projects" do
          html = cell("decidim/accountability/result_history", result).call
          expect(html).to have_content("It was included in this project:")
        end
      end

      context "when a result has been linked in a meeting" do
        let(:meeting_component) do
          create(:component, manifest_name: :meetings, participatory_space: result.component.participatory_space)
        end
        let(:meeting) { create(:meeting, :published, component: meeting_component) }

        before do
          meeting.link_resources([result], "meetings_through_proposals")
        end

        it "shows related meetings" do
          html = cell("decidim/accountability/result_history", result).call
          expect(html).to have_content("It was discussed in this meeting:")
        end
      end
    end
  end
end
