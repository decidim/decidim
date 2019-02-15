# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalActivityCell, type: :cell do
      controller Decidim::LastActivitiesController

      let!(:proposal) { create(:proposal) }
      let(:hashtag) { create(:hashtag, name: "myhashtag") }
      let(:action_log) do
        create(
          :action_log,
          resource: proposal,
          organization: proposal.organization,
          component: proposal.component,
          participatory_space: proposal.participatory_space
        )
      end

      context "when rendering" do
        it "renders the card" do
          html = cell("decidim/proposals/proposal_activity", action_log).call
          expect(html).to have_css(".card-data")
          expect(html).to have_content("New proposal")
        end

        context "when the proposal has a hashtags" do
          before do
            body = "Proposal with #myhashtag"
            parsed_body = Decidim::ContentProcessor.parse(body, current_organization: proposal.organization)
            proposal.body = parsed_body.rewrite
            proposal.save
          end

          it "correctly renders proposals with mentions" do
            html = cell("decidim/proposals/proposal_activity", action_log).call
            expect(html).to have_no_content("gid://")
            expect(html).to have_content("#myhashtag")
          end
        end
      end
    end
  end
end
