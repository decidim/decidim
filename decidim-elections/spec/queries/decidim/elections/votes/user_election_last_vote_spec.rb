# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections::Votes
  describe LastVoteForVoter do
    subject { described_class.new(election, voter_id).query }

    let(:election) { create :election }
    let(:voter_id) { "a voter id" }

    describe "when there are votes for the voter id and the election" do
      let!(:last_voter_election_vote) { create(:vote, election:, voter_id:, created_at: 1.day.from_now) }
      let!(:voter_election_votes) { create_list(:vote, 3, election:, voter_id:) }
      let!(:recent_other_voters_vote) { create(:vote, election:, created_at: 3.days.from_now) }
      let!(:other_voters_votes) { create_list(:vote, 2, election:) }
      let!(:recent_other_elections_vote) { create(:vote, election:, created_at: 3.days.from_now) }
      let!(:other_elections_votes) { create_list(:vote, 2, voter_id:) }

      it "gets the most recent voter's vote in the specified election" do
        expect(subject).to eq(last_voter_election_vote)
      end
    end

    describe "when there are votes for the voter id but not for the election" do
      let!(:other_elections_votes) { create_list(:vote, 2, voter_id:) }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    describe "when there are votes for other voter ids in the specified election" do
      let!(:other_voters_votes) { create_list(:vote, 2, election:) }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
