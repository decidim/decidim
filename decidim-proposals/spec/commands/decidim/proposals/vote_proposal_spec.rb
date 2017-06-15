# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VoteProposal do
      describe "call" do
        let(:proposal) { create(:proposal) }
        let(:current_user) { create(:user, organization: proposal.feature.organization) }
        let(:command) { described_class.new(proposal, current_user) }

        describe "when the vote is not valid" do
          before do
            allow_any_instance_of(ProposalVote).to receive(:valid?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new vote for the proposal" do
            expect {
              command.call
            }.to change { ProposalVote.count }.by(0)
          end
        end

        describe "when the vote is valid" do
          before do
            allow_any_instance_of(ProposalVote).to receive(:valid?).and_return(true)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new vote for the proposal" do
            expect {
              command.call
            }.to change { ProposalVote.count }.by(1)
          end
        end
      end
    end
  end
end
