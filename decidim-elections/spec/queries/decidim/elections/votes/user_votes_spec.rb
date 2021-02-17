# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections::Votes
  describe UserVotes do
    subject { described_class.new(user) }

    let(:user) { create :user }
    let!(:user_votes) { create_list(:vote, 3, user: user) }
    let!(:other_votes) { create_list(:vote, 2) }

    describe "query" do
      it "includes the user's votes" do
        expect(subject).to include(*user_votes)
      end

      it "excludes the other users' votes" do
        expect(subject).not_to include(*other_votes)
      end
    end
  end
end
