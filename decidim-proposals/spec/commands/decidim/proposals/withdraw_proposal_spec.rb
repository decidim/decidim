# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe WithdrawProposal do
      let(:proposal) { create(:proposal) }

      before do
        proposal.save!
      end

      describe "when current user IS the author of the proposal" do
        let(:current_user) { proposal.creator_author }
        let(:command) { described_class.new(proposal, current_user) }

        context "and the proposal has no votes" do
          it "withdraws the proposal" do
            expect do
              expect { command.call }.to broadcast(:ok)
            end.not_to change(Decidim::Proposals::Proposal, :count)
            expect(proposal).to be_withdrawn
            expect(proposal.withdrawn_at).to be_present
          end
        end

        context "and the proposal HAS some votes" do
          before do
            proposal.votes.create!(author: current_user)
          end

          it "is not able to withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:has_votes)
            end.not_to change(Decidim::Proposals::Proposal, :count)
            expect(proposal).not_to be_withdrawn
            expect(proposal.withdrawn_at).not_to be_present
          end
        end
      end
    end
  end
end
