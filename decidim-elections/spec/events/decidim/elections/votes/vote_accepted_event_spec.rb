# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Votes::VoteAcceptedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.votes.accepted_votes" }
  let(:vote) { create(:vote) }
  let(:extra) { { vote:, verify_url: } }
  let(:resource) { vote.election }
  let(:encrypted_vote_hash) { vote.encrypted_vote_hash }
  let(:resource_name) { resource.title["en"] }
  let(:verify_url) { Decidim::EngineRouter.main_proxy(resource.component).election_vote_verify_url(resource, vote_id: encrypted_vote_hash) }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Your vote for #{resource_name} was accepted.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Your vote was accepted! Using your voting token: #{encrypted_vote_hash}, you can verify your vote <a href=\"#{verify_url}\">here</a>.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you've voted for the #{resource_name} election.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("Your vote was accepted. Verify your vote <a href=\"#{verify_url}\">here</a> using your vote token: #{encrypted_vote_hash}")
    end
  end
end
