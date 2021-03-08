# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections::Votes
  describe ElectionVotes do
    subject { described_class.new(election) }

    let(:election) { create :election }
    let!(:election_votes) { create_list(:vote, 3, election: election) }
    let!(:other_votes) { create_list(:vote, 2) }

    describe "query" do
      it "includes the election's votes" do
        expect(subject).to include(*election_votes)
      end

      it "excludes the other elections' votes" do
        expect(subject).not_to include(*other_votes)
      end
    end
  end
end
