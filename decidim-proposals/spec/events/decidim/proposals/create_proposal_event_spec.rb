# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CreateProposalEvent do
  subject do
    described_class.new(resource: proposal, event_name: event_name, user: user, extra: {})
  end

  let(:organization) { proposal.organization }
  let(:proposal) { create :proposal }
  let(:proposal_author) { proposal.author }
  let(:event_name) { "decidim.events.proposals.proposal_created" }
  let(:user) { create :user, organization: organization }
  let(:resource_path) { resource_locator(proposal).path }

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("New proposal by @#{proposal_author.nickname}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Hi,\n#{proposal_author.name} @#{proposal_author.nickname}, who you are following, has created a new proposal, check it out and contribute:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following @#{proposal_author.nickname}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{proposal.title}</a> proposal was created by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{proposal_author.nickname}\">#{proposal_author.name} @#{proposal_author.nickname}</a>.")
    end
  end
end
