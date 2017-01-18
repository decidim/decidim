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
    end
  end
end
