# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalEndorsedEvent do
  include_context "simple event"

  let(:event_name) { "decidim.events.users.profile_updated" }
  let(:resource) { proposal }
  let(:author) { create :user, organization: proposal.organization }

  let(:extra) { { endorser: author } }
  let(:proposal) { create :proposal }
  let(:endorsement) { create :proposal_endorsement, proposal: proposal, author: author }
  let(:resource_path) { resource_locator(proposal).path }
  let(:follower) { create(:user, organization: proposal.organization) }
  let(:follow) { create(:follow, followable: author, user: follower) }

  it_behaves_like "a simple event"

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
      expect(subject.email_subject).to eq("#{author_presenter.nickname} has endorsed a new proposal")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("#{author.name} #{author_presenter.nickname}, who you are following," \
         " has just endorsed a proposal that may be interesting to you, check it out and contribute:")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{proposal.title}</a> proposal has been endorsed by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{author.nickname}\">#{author.name} #{author_presenter.nickname}</a>.")
    end
  end
end
