# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalRankingsHelper do
        let(:component) { create(:proposal_component) }

        let!(:proposal1) { create :proposal, component:, proposal_votes_count: 4 }
        let!(:proposal2) { create :proposal, component:, proposal_votes_count: 2 }
        let!(:proposal3) { create :proposal, component:, proposal_votes_count: 2 }
        let!(:proposal4) { create :proposal, component:, proposal_votes_count: 1 }

        let!(:external_proposal) { create :proposal, proposal_votes_count: 8 }

        describe "ranking_for" do
          it "returns the ranking considering only sibling proposals" do
            result = helper.ranking_for(proposal1, proposal_votes_count: :desc)

            expect(result).to eq(ranking: 1, total: 4)
          end

          it "breaks ties by ordering by ID" do
            result = helper.ranking_for(proposal3, proposal_votes_count: :desc)

            expect(result).to eq(ranking: 3, total: 4)
          end
        end
      end
    end
  end
end
