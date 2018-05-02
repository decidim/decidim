# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::EndorseInitiativeEvent do
  subject do
    described_class.new(resource: initiative, event_name: event_name, user: user, extra: {})
  end

  let(:organization) { initiative.organization }
  let(:initiative) { create :initiative }
  let(:initiative_author) { initiative.author }
  let(:event_name) { "decidim.events.initiatives.initiative_endorsed" }
  let(:user) { create :user, organization: organization }
  let(:resource_path) { resource_locator(initiative).path }

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
      expect(subject.email_subject).to eq("Initiative endorsed by @#{initiative_author.nickname}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{initiative_author.name} @#{initiative_author.nickname}, who you are following, has endorsed the following initiative, maybe you want to contribute to the conversation:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following @#{initiative_author.nickname}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{initiative.title["en"]}</a> initiative was endorsed by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{initiative_author.nickname}\">#{initiative_author.name} @#{initiative_author.nickname}</a>.")
    end
  end
end
