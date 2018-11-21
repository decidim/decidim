# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Withdraw do
      let!(:proposal) { create(:proposal) }
      let!(:emendation) { create(:proposal) }
      let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }

      describe "when current user IS the author of the amendment" do
        let(:current_user) { emendation.creator_author }
        let(:command) { described_class.new(emendation, current_user) }

        context "and the amendment has no supports" do
          it "withdraws the amendment" do
            expect do
              expect { command.call }.to broadcast(:ok)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
            expect(emendation.amendment.state).to eq("withdrawn")
            expect(emendation.state).to eq("withdrawn")
          end
        end

        context "and the amendment HAS some supports" do
          before do
            emendation.votes.create!(author: current_user)
          end

          it "is not able to withdraw the amendment" do
            expect do
              expect { command.call }.to broadcast(:invalid)
            end.to change { Decidim::Proposals::Proposal.count }.by(0)
            expect(emendation.amendment.state).not_to eq("withdrawn")
            expect(emendation.state).not_to eq("withdrawn")
          end
        end
      end
    end
  end
end
