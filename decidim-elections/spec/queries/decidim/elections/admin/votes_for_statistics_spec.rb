# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::VotesForStatistics do
  subject { described_class.for(election) }

  let!(:election) { create :election, :bb_test, :vote }
  let!(:user_1) { create :user, :confirmed }
  let!(:user_2) { create :user, :confirmed }
  let!(:user_1_votes) { create_list :vote, 3, election: election, status: "accepted", voter_id: "voter_#{user_1.id}" }
  let!(:user_2_votes) { create :vote, election: election, status: "rejected", voter_id: "voter_#{user_2.id}" }

  describe "query" do
    it "returns the id and voter id for accepted votes only" do
      expect(subject).to eql([3, 1])
    end
  end
end
