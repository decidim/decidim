# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesHelper do
      let(:organization) { create(:organization) }
      let(:limit) { 10 }
      let(:votes_enabled) { true }
      let(:proposal_component) { create(:proposal_component, organization:) }
      let(:user) { create(:user, organization:) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:current_component).and_return(proposal_component)
        allow(helper).to receive(:current_settings).and_return(double(votes_enabled?: votes_enabled))
        allow(helper).to receive(:component_settings).and_return(double(vote_limit: limit))
      end

      describe "#vote_button_classes" do
        it "returns small buttons classes from proposals list" do
          expect(helper.vote_button_classes(true)).to eq("card__button")
        end

        it "returns expanded buttons classes if it's not from proposals list'" do
          expect(helper.vote_button_classes(false)).to eq("expanded")
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

      describe "#vote_limit_enabled?" do
        context "when the current_settings vote_limit is less or equal 0" do
          let(:limit) { 0 }

          it "returns false" do
            expect(helper).not_to be_vote_limit_enabled
          end
        end

        context "when the current_settings vote_limit is greater than 0" do
          it "returns true" do
            expect(helper).to be_vote_limit_enabled
          end
        end
      end

      describe "#remaining_votes_count_for" do
        it "returns the remaining votes for a user based on the component votes limit" do
          proposal = create(:proposal, component: proposal_component)
          create(:proposal_vote, author: user, proposal:)

          expect(helper.remaining_votes_count_for(user)).to eq(9)
        end
      end
    end
  end
end
