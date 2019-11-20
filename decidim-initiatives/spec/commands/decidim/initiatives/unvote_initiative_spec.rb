# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UnvoteInitiative do
      describe "User unvotes initiative" do
        let(:vote) { create(:initiative_user_vote) }
        let(:command) { described_class.new(vote.initiative, vote.author, nil) }

        it "broadcasts ok" do
          expect(vote).to be_valid
          expect { command.call }.to broadcast :ok
        end

        it "Removes the vote" do
          expect(vote).to be_valid
          expect do
            command.call
          end.to change(InitiativesVote, :count).by(-1)
        end

        it "decreases the vote counter by one" do
          initiative = vote.initiative
          expect(InitiativesVote.count).to eq(1)
          expect do
            command.call
            initiative.reload
          end.to change { initiative.online_votes_count }.by(-1)
        end
      end
    end
  end
end
