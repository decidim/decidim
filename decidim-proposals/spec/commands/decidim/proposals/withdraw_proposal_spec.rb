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
        let(:current_user) { proposal.author }
        let(:command) { described_class.new(proposal, current_user) }

        context "and the proposal has no supports" do
          it "should withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:ok)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
            expect(proposal.state).to eq('withdrawn')
          end
        end
        context "and the proposal HAS some supports" do
          before do
            proposal.votes.create!(author: current_user)
          end
          it "should not be able to withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:invalid)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
            expect(proposal.state).to_not eq('withdrawn')
          end
        end
      end
      describe "when current user is NOT the author of the proposal" do
        let(:current_user) { create(:user, organization: proposal.feature.organization) }
        let(:command) { described_class.new(proposal, current_user) }

        context "and the proposal has no supports" do
          it "should not be able to withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:invalid)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
            expect(proposal.state).to_not eq('withdrawn')
          end
        end
        context "and the proposal has some supports" do
          it "should not be able to withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:invalid)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
            expect(proposal.state).to_not eq('withdrawn')
          end
        end
      end
    end
  end
end
