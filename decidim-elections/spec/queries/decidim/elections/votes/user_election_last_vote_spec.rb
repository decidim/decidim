# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections::Votes
  describe UserElectionLastVote do
    subject { described_class.new(user, election).query }

    let(:election) { create :election }
    let(:user) { create :user }

    let!(:last_user_election_vote) { create(:vote, election: election, user: user, created_at: 1.day.from_now) }
    let!(:user_election_votes) { create_list(:vote, 3, election: election, user: user) }
    let!(:recent_other_users_vote) { create(:vote, election: election, created_at: 3.days.from_now) }
    let!(:other_users_votes) { create_list(:vote, 2, election: election) }
    let!(:recent_other_elections_vote) { create(:vote, election: election, created_at: 3.days.from_now) }
    let!(:other_elections_votes) { create_list(:vote, 2, user: user) }

    describe "query" do
      it "is the most recent user's vote in the specified election" do
        expect(subject).to eq(last_user_election_vote)
      end
    end
  end
end
