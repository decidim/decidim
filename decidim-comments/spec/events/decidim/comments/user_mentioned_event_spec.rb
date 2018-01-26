# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::UserMentionedEvent do
  subject do
    described_class.new(resource: resource, event_name: event_name, user: user, extra: extra)
  end

  let(:resource) { comment.commentable }
  let(:organization) { resource.organization }
  let(:comment) { create :comment }
  let(:comment_author) { comment.author }
  let(:event_name) { "decidim.events.comments.user_mentioned" }
  let(:user) { create :user, organization: organization }
  let(:extra) { { comment_id: comment.id } }
  let(:resource_path) { resource_locator(resource).path }

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
      expect(subject.email_subject).to eq("You have been mentioned in #{resource.title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("You have been mentioned")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you have been mentioned in \"#{resource.title}\".")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("You have been mentioned in <a href=\"#{resource_path}\">#{resource.title}</a>")

      expect(subject.notification_title)
        .to include(" by <a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a>")
    end
  end
end
