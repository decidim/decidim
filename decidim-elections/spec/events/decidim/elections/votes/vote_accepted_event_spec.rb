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
  let(:email_subject) { "Your vote for #{resource_name} was accepted." }
  let(:email_intro) { "Your vote was accepted! Using your voting token: #{encrypted_vote_hash}, you can verify your vote <a href=\"#{verify_url}\">here</a>." }
  let(:email_outro) { "You have received this notification because you have voted for the #{resource_name} election." }
  let(:notification_title) { "Your vote was accepted. Verify your vote <a href=\"#{verify_url}\">here</a> using your vote token: #{encrypted_vote_hash}" }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
