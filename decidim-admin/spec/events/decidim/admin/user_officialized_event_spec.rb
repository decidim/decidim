# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::UserOfficializedEvent do
  subject do
    described_class.new(resource: user, event_name: event_name, user: follower, extra: {})
  end

  let(:organization) { follower.organization }
  let(:follower) { create :user }
  let(:event_name) { "decidim.events.users.user_officialized" }
  let(:user) { create :user, organization: organization }

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
      expect(subject.email_subject).to eq("@#{user.nickname} updated their profile")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The <a href=\"/profiles/#{user.nickname}\">profile page</a> of #{user.name} (@#{user.nickname}), who you are following, has been updated.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following @#{user.nickname}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to include("<a href=\"/profiles/#{user.nickname}\">profile page</a>")
    end
  end
end
