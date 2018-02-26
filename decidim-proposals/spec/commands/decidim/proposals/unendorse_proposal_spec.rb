# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UnendorseProposal do
      describe "User unendorse proposal" do
        let(:endorsement) { create(:proposal_endorsement) }
        let(:command) { described_class.new(endorsement.proposal, endorsement.author) }

        it "broadcasts ok" do
          expect(endorsement).to be_valid
          expect { command.call }.to broadcast :ok
        end

        it "Removes the endorsement" do
          expect(endorsement).to be_valid
          expect do
            command.call
          end.to change(ProposalEndorsement, :count).by(-1)
        end

        it "Decreases the endorsements counter by one" do
          proposal = endorsement.proposal
          expect(ProposalEndorsement.count).to eq(1)
          expect do
            command.call
            proposal.reload
          end.to change { proposal.proposal_endorsements_count }.by(-1)
        end
      end

      describe "Organization unendorses proposal" do
        let(:endorsement) { create(:user_group_proposal_endorsement) }
        let(:command) { described_class.new(endorsement.proposal, endorsement.author, endorsement.user_group) }

        it "broadcasts ok" do
          expect(endorsement).to be_valid
          expect { command.call }.to broadcast :ok
        end

        it "Removes the endorsement" do
          expect(endorsement).to be_valid
          expect do
            command.call
          end.to change(ProposalEndorsement, :count).by(-1)
        end

        it "Do not decreases the endorsement counter by one" do
          expect(endorsement).to be_valid
          command.call

          proposal = endorsement.proposal
          proposal.reload
          expect(proposal.proposal_endorsements_count).to be_zero
        end
      end
    end
  end
end
