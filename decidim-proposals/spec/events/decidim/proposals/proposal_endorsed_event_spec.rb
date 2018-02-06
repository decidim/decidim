# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalEndorsedEvent do
  subject do
    extra = {
      endorser: endorsement_author
    }
    described_class.new(resource: proposal, event_name: event_name, user: follower, extra: extra)
  end

  let(:proposal) { create :proposal }
  let(:endorsement_author) { create :user, organization: proposal.organization }
  let(:endorsement) { create :proposal_endorsement, proposal: proposal, author: endorsement_author }
  let(:event_name) { "decidim.events.proposals.proposal_endorsed" }
  let(:resource_path) { resource_locator(proposal).path }
  let(:follower) { create(:user, organization: proposal.organization) }
  let(:follow) { create(:follow, followable: endorsement_author, user: follower) }

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
      expect(subject.email_subject).to eq("@#{endorsement_author.nickname} has endorsed a new proposal")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Hi,\n#{endorsement_author.name} @#{endorsement_author.nickname}, who you are following," \
         " has just endorsed a proposal that may be interesting to you, check it out and contribute:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following @#{endorsement_author.nickname}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{proposal.title}</a> proposal has been endorsed by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{endorsement_author.nickname}\">#{endorsement_author.name} @#{endorsement_author.nickname}</a>.")
    end
  end
end
