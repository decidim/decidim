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

        context "and the proposal has no supports" do
          it "withdraws the proposal" do
            expect do
              expect { command.call }.to broadcast(:ok)
            end.not_to change(Decidim::Proposals::Proposal, :count)
            expect(proposal.state).to eq("withdrawn")
          end
        end

        context "and the proposal HAS some supports" do
          before do
            proposal.votes.create!(author: current_user)
          end

          it "is not able to withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:has_supports)
            end.not_to change(Decidim::Proposals::Proposal, :count)
            expect(proposal.state).not_to eq("withdrawn")
          end
        end
      end
    end
  end
end
