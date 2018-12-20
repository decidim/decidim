# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentCreatedEvent do
  include_context "when a simple event"

  let(:resource) { comment.commentable }
  let(:comment) { create :comment }
  let(:comment_author) { comment.author }
  let(:event_name) { "decidim.events.comments.comment_created" }
  let(:extra) { { comment_id: comment.id } }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("There is a new comment from #{comment_author.name} in #{resource.title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{resource.title} has been commented. You can read the comment in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{resource.title}\" or its author. You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("There is a new comment from <a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a>")

      expect(subject.notification_title)
        .to include(" in <a href=\"#{resource_path}#comment_#{comment.id}\">#{resource.title}</a>")
    end
  end

  describe "resource_text" do
    it "outputs the comment body" do
      expect(subject.resource_text).to eq comment.body
    end
  end
end
