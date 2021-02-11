# frozen_string_literal: true

require "spec_helper"

describe "decidim_elections:scheduled_tasks", type: :task do
  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "with elections to start", :vcr do
    let!(:election) { create :election, :bb_test, :key_ceremony_ended }

    before { task.execute }

    it "requests starting the voting period" do
      check_message_printed("Starting vote period for election ##{election.id}:")
      check_message_printed("✓ Voting period start requested.")
    end
  end

  context "with elections to end", :vcr do
    let!(:election) { create :election, :bb_test, :vote, :finished }

    before { task.execute }

    it "requests ending the voting period" do
      check_message_printed("Ending vote period for election ##{election.id}:")
      check_message_printed("✓ Voting period end requested.")
    end
  end

  context "with elections that shouldn't be affected" do
    let!(:election1) { create :election, :key_ceremony_ended, start_time: 1.day.from_now }
    let!(:election2) { create :election, :vote, :upcoming }
    let!(:election3) { create :election, :vote, :ongoing }

    before { task.execute }

    it "don't modify them" do
      expect(election1.reload).to be_bb_key_ceremony_ended
      expect(election2.reload).to be_bb_vote
    end
  end

  context "with pending votes", :vcr do
    let!(:vote) { create :vote, message_id: "decidim-test-authority.10004.vote.cast+v.voter-1" }

    before { task.execute }

    it "updates the vote status" do
      check_message_printed("Checking status for Vote ##{vote.id}:")
      check_message_printed("Vote status updated")
    end
  end

  context "with votes that shouldn't be affected" do
    let!(:vote) { create :vote, status: "accepted" }

    before { task.execute }

    it "doesn't update the status" do
      expect(vote.reload).to be_accepted
    end
  end
end
