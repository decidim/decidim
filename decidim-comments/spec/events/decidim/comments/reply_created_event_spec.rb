# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::ReplyCreatedEvent do
  include_context "when it's a comment event"
  let(:event_name) { "decidim.events.comments.reply_created" }
  let(:comment) { create :comment, commentable: parent_comment, root_commentable: parent_comment.root_commentable }
  let(:parent_comment) { create :comment }
  let(:resource) { comment.root_commentable }

  it_behaves_like "a comment event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("#{comment_author_name} has replied your comment in #{translated resource.title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{comment_author_name} has replied your comment in #{resource_title}. You can read it in this page:")
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
        .to start_with("<a href=\"/profiles/#{comment_author.nickname}\">#{comment_author_name} @#{comment_author.nickname}</a> has replied your comment in")

      expect(subject.notification_title)
        .to end_with("your comment in <a href=\"#{resource_path}#comment_#{comment.id}\">#{translated resource.title}</a>")
    end
  end
end
