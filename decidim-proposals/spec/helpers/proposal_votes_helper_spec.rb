# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesHelper do
      describe "#vote_button_classes" do
        it "returns small buttons classes from proposals list" do
          expect(helper.vote_button_classes(true)).to eq("small")
        end

        it "returns expanded buttons classes if it's not from proposals list'" do
          expect(helper.vote_button_classes(false)).to eq("expanded button--sc")
        end
      end

      describe "#votes_count_classes" do
        it "returns small count classes from proposals list" do
          expect(helper.votes_count_classes(true)).to eq(number: "card__support__number", label: "")
        end

        it "returns expanded count classes if it's not from proposals list'" do
          expect(helper.votes_count_classes(false)).to eq(number: "extra__suport-number", label: "extra__suport-text")
        end
      end

      describe "#remaining_votes_for" do
        let(:organization) { create(:organization) }
        let(:vote_limit) { 10 }
        let(:proposal_feature) { create(:proposal_feature, organization: organization) }

        it "returns the remaining votes for a user based on the feature votes limit" do
          expect(helper).to receive(:current_feature).and_return(proposal_feature)
          expect(helper).to receive(:feature_settings).and_return(double(vote_limit: vote_limit))

          user = create(:user, organization: organization)
          proposal = create(:proposal, feature: proposal_feature)
          create(:proposal_vote, author: user, proposal: proposal)

          expect(helper.remaining_votes_for(user)).to eq(9)
        end
      end
    end
  end
end
