# frozen_string_literal: true

require "spec_helper"

describe "decidim_elections:scheduled_tasks", type: :task do
  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "with elections to open", :vcr do
    let!(:election) { create :election, :bb_test, :ready }

    before { task.execute }

    it "opens the Ballot Box" do
      check_message_printed("Opening Election ##{election.id}:")
      check_message_printed("Ballot Box opened. New bulletin board status: vote")
    end
  end

  context "with elections to close", :vcr do
    let!(:election) { create :election, :bb_test, :vote, :finished }

    before { task.execute }

    it "closes the Ballot Box" do
      check_message_printed("Closing Election ##{election.id}:")
      check_message_printed("Ballot Box closed. New bulletin board status: tally")
    end
  end

  context "with elections that shouldn't be affected" do
    let!(:election1) { create :election, :ready, start_time: 1.day.from_now }
    let!(:election2) { create :election, :vote, :upcoming }
    let!(:election3) { create :election, :vote, :ongoing }

    before { task.execute }

    it "don't modify them" do
      expect(election1.reload).to be_bb_ready
      expect(election2.reload).to be_bb_vote
    end
  end
end
