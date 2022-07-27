# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Votes
  describe InPersonVoteForVoter do
    subject { described_class.new(election, voter_id).query }

    let(:election) { create :election }
    let(:voter_id) { "a voter id" }

    describe "when there is a vote for the voter id and the election" do
      let!(:voter_election_vote) { create(:in_person_vote, :accepted, election:, voter_id:) }
      let!(:other_voters_votes) { create_list(:in_person_vote, 2, :accepted, election:) }
      let!(:other_elections_votes) { create_list(:in_person_vote, 2, :accepted, voter_id:) }

      it "gets the accepted voter's vote in the specified election" do
        expect(subject).to eq(voter_election_vote)
      end
    end

    describe "when there are votes for the voter id but not accepted" do
      let!(:rejected_election_vote) { create(:in_person_vote, :rejected, election:, voter_id:) }
      let!(:other_elections_votes) { create_list(:in_person_vote, 2, :accepted, voter_id:) }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    describe "when there are rejected and accepted votes for the voter id in the specified election" do
      let!(:voter_election_vote) { create(:in_person_vote, :accepted, election:, voter_id:) }
      let!(:rejected_election_vote) { create(:in_person_vote, :rejected, election:, voter_id:) }

      it "gets the accepted voter's vote in the specified election" do
        expect(subject).to eq(voter_election_vote)
      end
    end
  end
end
