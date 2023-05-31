# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::RevokeMembershipRequestEvent do
  subject do
    described_class.new(
      resource: initiative,
      event_name:,
      user: [membership_request.user],
      user_role: :affected_user,
      extra: { author: }
    )
  end

  let(:event_name) { "decidim.events.initiatives.approve_membership_request" }
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, :created, organization:) }
  let(:author) { initiative.author }
  let(:author_profile_url) { Decidim::UserPresenter.new(author).profile_url }
  let(:author_nickname) { Decidim::UserPresenter.new(author).nickname }
  let(:membership_request) { create(:initiatives_committee_member, initiative:, state: "requested") }
  let(:resource_url) { resource_locator(initiative).url }
  let(:resource_title) { translated(initiative.title) }

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
      expect(subject.email_subject).to eq("#{author_nickname} rejected your application to the promoter committee")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{author_nickname} rejected your application to be part of the promoter committee for the following initiative #{resource_title}.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You received this notification because you applied to this initiative: #{resource_title}.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("<a href=\"#{author_profile_url}\">#{author_nickname}</a> rejected your application to be part of the promoter committee for the following initiative <a href=\"#{resource_url}\">#{resource_title}</a>.")
    end
  end
end
