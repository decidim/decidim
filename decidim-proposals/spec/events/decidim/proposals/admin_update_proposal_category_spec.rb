# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::UpdateProposalCategoryEvent do
  subject do
    described_class.new(resource: proposal, event_name: event_name, user: user, extra: {})
  end

  let(:organization) { proposal.organization }
  let(:proposal) { create :proposal }
  let(:proposal_author) { proposal.author }
  let(:event_name) { "decidim.events.proposals.proposal_update_category" }
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
      expect(subject.email_subject)
      .to eq("The #{proposal.title} proposal category has been updated")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Hi,\n#{proposal_author.name} @#{proposal_author.nickname}, an admin has updated your proposal #{proposal.title}, check it out:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are the author of the proposal. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{proposal.title}</a> proposal has been updated by an admin.")
    end
  end
end
