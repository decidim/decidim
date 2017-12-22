# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe WithdrawProposal do
      let(:proposal) { create(:proposal) }
      let(:current_user) { Decidim::Proposals::Proposal.find(proposal.decidim_author_id) }
      let(:command) { described_class.new(proposal, current_user) }

      describe "when current user IS the author of the proposal" do
        before do
          puts "PRODOPSODIDS: #{proposal.author.id} =? #{current_user.id}"
        end
        context "and the proposal has no supports" do
          it "should withdraw the proposal" do
            expect do
              command.call
            end.to change { Decidim::Proposals::Proposal.count }.by(-1)
          end
        end
        context "and the proposal HAS some supports" do
          it "should not be able to withdraw the proposal" do
            expect do
              expect { command.call }.to broadcast(:invalid)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
          end
        end
      end
      describe "when current user is NOT the author of the proposal" do
        context "and the proposal has no supports" do
          it "should not be able to withdraw the proposal" do
            expect do
              command.call
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
          end
        end
        context "and the proposal has some supports" do
          it "should not be able to withdraw the proposal" do
            expect do
              command.call
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
          end
        end
      end
    end
  end
end
