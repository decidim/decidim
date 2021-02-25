# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::UpdateVoteStatus do
  subject { described_class.new(vote) }

  let(:vote) { create :vote }
  let(:method_name) { :get_pending_message_status }
  let(:response) { :accepted }

  before do
    allow(Decidim::Elections.bulletin_board).to receive(method_name).and_return(response)
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates the vote status" do
    subject.call
    expect(vote.status).to eq "accepted"
  end

  it "sends a notification to voter" do
    expect(Decidim::EventsManager)
      .to receive(:publish)
      .with(
        event: "decidim.events.elections.votes.accepted_votes",
        event_class: Decidim::Elections::Votes::VoteAcceptedEvent,
        resource: vote.election,
        affected_users: [vote.user],
        extra: {
          vote: vote
        }
      )
    subject.call
  end
end
