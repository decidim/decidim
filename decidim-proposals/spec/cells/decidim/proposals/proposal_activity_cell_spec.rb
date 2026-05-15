# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalActivityCell, type: :cell do
      controller Decidim::LastActivitiesController

      let!(:proposal) { create(:proposal) }
      let(:action) { :publish }
      let(:action_log) do
        create(
          :action_log,
          action:,
          resource: proposal,
          organization: proposal.organization,
          component: proposal.component,
          participatory_space: proposal.participatory_space
        )
      end

      context "when rendering" do
        it "renders the card" do
          html = cell("decidim/proposals/proposal_activity", action_log).call
          expect(html).to have_css("[data-activity]")
        end

        context "when action is update" do
          let(:action) { :update }

          it "renders the correct title" do
            html = cell("decidim/proposals/proposal_activity", action_log).call
            expect(html).to have_css("[data-activity]")
            expect(html).to have_content("Proposal updated")
          end
        end

        context "when action is create" do
          let(:action) { :create }

          it "renders the correct title" do
            html = cell("decidim/proposals/proposal_activity", action_log).call
            expect(html).to have_css("[data-activity]")
            expect(html).to have_content("New proposal")
          end
        end

        context "when action is publish" do
          it "renders the correct title" do
            html = cell("decidim/proposals/proposal_activity", action_log).call
            expect(html).to have_css("[data-activity]")
            expect(html).to have_content("New proposal")
          end
        end
      end

      context "when the proposal has a mention" do
        let(:organization) { proposal.organization }

        before do
          body = "Proposal with @user"
          parsed_body = Decidim::ContentProcessor.parse(body, current_organization: proposal.organization)
          proposal.body = { en: parsed_body.rewrite }
          proposal.save
        end

        include_context "with editor content containing mentions"

        it "correctly renders proposals with mentions" do
          html = cell("decidim/proposals/proposal_activity", action_log).call
          expect(html).to have_no_content("gid://")
        end
      end
    end
  end
end
