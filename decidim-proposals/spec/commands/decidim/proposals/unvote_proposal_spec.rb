# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UnvoteProposal do
      describe "call" do
        let(:proposal) { create(:proposal) }
        let(:current_user) { create(:user, organization: proposal.component.organization) }
        let!(:proposal_vote) { create(:proposal_vote, author: current_user, proposal:) }
        let(:command) { described_class.new(proposal, current_user) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "deletes the proposal vote for that user" do
          expect do
            command.call
          end.to change(ProposalVote, :count).by(-1)
        end

        it "decrements the right score for that user" do
          Decidim::Gamification.set_score(current_user, :proposal_votes, 10)
          command.call
          expect(Decidim::Gamification.status_for(current_user, :proposal_votes).score).to eq(9)
        end
      end
    end
  end
end
