# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentCreatedEvent do
  let(:resource) { comment.commentable }
  let(:organization) { resource.organization }
  let(:comment) { create :comment }
  let(:comment_author) { comment.author }
  let(:event_name) { "decidim.events.comments.comment_created" }
  let(:user) { create :user, organization: organization }
  let(:extra) { { comment_id: comment.id } }
  let(:resource_path) { resource_locator(resource).path }

  subject do
    described_class.new(resource: resource, event_name: event_name, user: user, extra: extra)
  end

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
      expect(subject.email_subject).to eq "There is a new comment from #{comment_author.name} in #{resource.title}"
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq "\"#{resource.title}\" has been commented. You can read the comment in this page:"
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).to eq "You have received this notification because you are following \"#{resource.title}\". You can unfollow it from the previous link."
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to eq "There is a new comment from #{comment_author.name} in <a href=\"#{resource_path}\">#{resource.title}</a>"
    end
  end
end
