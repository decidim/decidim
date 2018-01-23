# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebateEvent do
  subject do
    described_class.new(resource: debate, event_name: event_name, user: user, extra: {})
  end

  let(:organization) { debate.organization }
  let(:debate) { create :debate, :with_author }
  let(:debate_author) { debate.author }
  let(:event_name) { "decidim.events.debates.debate_created" }
  let(:user) { create :user, organization: organization }
  let(:resource_path) { resource_locator(debate).path }

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
      expect(subject.email_subject).to eq("New debate by @#{debate_author.nickname}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Hi,\n#{debate_author.name} @#{debate_author.nickname}, who you are following, has created a new debate, check it out and contribute:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following @#{debate_author.nickname}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{debate.title["en"]}</a> debate was created by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{debate_author.nickname}\">#{debate_author.name} @#{debate_author.nickname}</a>.")
    end
  end
end
