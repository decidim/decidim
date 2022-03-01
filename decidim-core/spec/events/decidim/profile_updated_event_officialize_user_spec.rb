# frozen_string_literal: true

require "spec_helper"

describe Decidim::ProfileUpdatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.users.user_officialized" }
  let(:resource) { create :user }
  let(:author) { resource }

  it_behaves_like "a simple event", true

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("#{resource.name} has been officialized")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("Participant #{resource.name} (@#{resource.nickname}) has been officialized.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are an administrator of the organization.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to eq("Participant #{resource.name} (@#{resource.nickname}) has been officialized.")
    end
  end
end
