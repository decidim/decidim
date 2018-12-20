# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::ReplyCreatedEvent do
  include_context "when a simple event"

  let(:resource) { comment.root_commentable }
  let(:resource_title) { comment.root_commentable.title }
  let(:parent_comment) { create :comment }
  let(:comment) { create :comment, commentable: parent_comment, root_commentable: parent_comment.root_commentable }
  let(:comment_author) { comment.author }
  let(:event_name) { "decidim.events.comments.reply_created" }
  let(:extra) { { comment_id: comment.id } }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("#{comment_author.name} has replied your comment in #{resource.title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{comment_author.name} has replied your comment in #{resource_title}. You can read it in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because your comment was replied.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to start_with("<a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a> has replied your comment in")

      expect(subject.notification_title)
        .to end_with("your comment in <a href=\"#{resource_path}#comment_#{comment.id}\">#{resource.title}</a>")
    end
  end

  describe "resource_text" do
    it "outputs the comment body" do
      expect(subject.resource_text).to eq comment.body
    end
  end
end
