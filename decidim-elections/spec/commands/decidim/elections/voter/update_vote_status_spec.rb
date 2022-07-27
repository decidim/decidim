# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::UpdateVoteStatus do
  subject { described_class.new(vote) }

  let(:election) { create :election }
  let(:vote) { create :vote, user:, email:, election: }
  let(:user) { create :user, organization: }
  let(:component) { election.component }
  let(:organization) { component.organization }
  let(:email) { "an_email@example.org" }
  let(:method_name) { :get_pending_message_status }
  let(:response) { :accepted }
  let(:verify_url) { "http://#{organization.host}:#{Capybara.server_port}/processes/#{component.participatory_space.slug}/f/#{component.id}/elections/#{election.id}/votes/#{vote.encrypted_vote_hash}/verify" }

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
          vote:,
          verify_url:
        }
      )
    subject.call
  end

  it "doesn't send an extra email" do
    expect(Decidim::Elections::VoteAcceptedMailer)
      .not_to receive(:notification)

    subject.call
  end

  context "when the vote doesn't have a user, but has an email address" do
    let(:user) { nil }
    let(:mailer) { double(:mailer) }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "updates the vote status" do
      subject.call
      expect(vote.status).to eq "accepted"
    end

    it "doesn't sends a notification" do
      expect(Decidim::EventsManager)
        .not_to receive(:publish)

      subject.call
    end

    it "sends an email" do
      allow(Decidim::Elections::VoteAcceptedMailer)
        .to receive(:notification)
        .with(vote, verify_url, I18n.locale.to_s)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_later)

      subject.call
    end
  end

  context "when the vote doesn't have a user not an email address" do
    let(:user) { nil }
    let(:email) { nil }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "updates the vote status" do
      subject.call
      expect(vote.status).to eq "accepted"
    end

    it "doesn't sends a notification" do
      expect(Decidim::EventsManager)
        .not_to receive(:publish)

      subject.call
    end

    it "doesn't send an email" do
      expect(Decidim::Elections::VoteAcceptedMailer)
        .not_to receive(:notification)

      subject.call
    end
  end

  context "when the Bulletin Board has rejected the vote" do
    let(:response) { :rejected }

    it "updates the vote status" do
      subject.call
      expect(vote.status).to eq "rejected"
    end
  end
end
