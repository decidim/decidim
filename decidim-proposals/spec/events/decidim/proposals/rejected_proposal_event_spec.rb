# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::RejectedProposalEvent do
  subject do
    described_class.new(resource: proposal, event_name: event_name, user: user, extra: {})
  end

  let(:organization) { proposal.organization }
  let(:proposal) { create :proposal }
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
      expect(subject.email_subject).to eq("A proposal you're following has been rejected")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The proposal \"#{proposal.title}\" has been rejected. You can read the answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{proposal.title}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{proposal.title}</a> proposal has been rejected")
    end
  end
end
