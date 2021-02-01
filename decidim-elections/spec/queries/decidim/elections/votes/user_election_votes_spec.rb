# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections::Votes
  describe UserElectionVotes do
    subject { described_class.new(user, election) }

    let(:election) { create :election }
    let(:user) { create :user }

    let!(:user_election_votes) { create_list(:vote, 3, election: election, user: user) }
    let!(:other_users_votes) { create_list(:vote, 2, election: election) }
    let!(:other_elections_votes) { create_list(:vote, 2, user: user) }

    describe "query" do
      it "includes the user & election's votes" do
        expect(subject).to include(*user_election_votes)
      end

      it "excludes the other elections' votes" do
        expect(subject).not_to include(*other_elections_votes)
      end

      it "excludes the other users' votes" do
        expect(subject).not_to include(*other_users_votes)
      end
    end
  end
end
