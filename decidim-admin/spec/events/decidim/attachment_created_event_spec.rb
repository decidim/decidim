# frozen_string_literal: true

require "spec_helper"

describe Decidim::AttachmentCreatedEvent do
  subject do
    described_class.new(resource: attachment, event_name: event_name, user: follower, extra: {})
  end

  let(:follower) { create :user }
  let(:event_name) { "decidim.events.attachment_created_event" }
  let(:attachment) { create(:attachment) }
  let(:attached_to_url) { Decidim::ResourceLocatorPresenter.new(attachment.attached_to).url }
  let(:resource_title) { attachment.attached_to.title["en"] }
  let(:resource_path) { attachment.url }

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
      expect(subject.email_subject).to eq("An update to #{resource_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("A new document has been added to #{resource_title}. You can see it from this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following #{resource_title}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("A <a href=\"#{resource_path}\">new document</a> has been added to <a href=\"#{attached_to_url}\">#{resource_title}</a>")
    end
  end
end
