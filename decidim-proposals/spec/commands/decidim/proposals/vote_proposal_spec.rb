# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VoteProposal do
      describe "call" do
        let(:proposal) { create(:proposal) }
        let(:current_user) { create(:user, organization: proposal.feature.organization) }
        let(:command) { described_class.new(proposal, current_user) }

        context "with normal conditions" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new vote for the proposal" do
            expect do
              command.call
            end.to change { ProposalVote.count }.by(1)
          end
        end

        context "when the vote is not valid" do
          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(ProposalVote).to receive(:valid?).and_return(false)
            # rubocop:enable RSpec/AnyInstance
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new vote for the proposal" do
            expect do
              command.call
            end.to change { ProposalVote.count }.by(0)
          end
        end

        context "when the maximum votes have been reached" do
          before do
            expect(proposal).to receive(:maximum_votes_reached?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
