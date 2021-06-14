# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Votes::PendingVotes do
  let(:pending_vote) { create(:vote) }
  let(:accepted_vote) { create(:vote, status: "accepted") }

  it "returns only votes with pending status" do
    expect(described_class.for).to match_array pending_vote
    expect(described_class.for).not_to match_array accepted_vote
  end
end
