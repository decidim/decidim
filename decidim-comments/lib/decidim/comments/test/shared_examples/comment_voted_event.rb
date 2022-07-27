# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a comment voted event" do
  include_context "when it's a comment event"

  let(:resource) { comment.commentable }

  let(:comment) { create :comment }
  let(:comment_vote) { create :comment_vote, comment: }
  let(:comment_vote_author) { comment_vote.author }

  let(:extra) { { comment_id: comment.id, author_id: comment_vote_author.id, weight:, downvotes: 100, upvotes: 999 } }
  let(:resource_title) { decidim_html_escape(translated(resource.title)) }
  let(:resource_text) { subject.resource_text }

  let(:verb) { weight.positive? ? "upvoted" : "downvoted" }

  describe "downvotes" do
    it "outputs the total downvotes" do
      expect(subject.downvotes).to eq(100)
    end
  end

  describe "upvotes" do
    it "outputs the total upvotes" do
      expect(subject.upvotes).to eq(999)
    end
  end

  describe "resource_text" do
    it "outputs the comment body" do
      expect(subject.resource_text).to eq comment.formatted_body
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Your comment in \"#{resource_title}\" has been #{verb}.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("Your comment in \"#{resource_title}\" has been #{verb}. It now has a total of 999 upvotes and 100 downvotes.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are the author of this comment.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("Your <a href=\"#{resource_path}#comment_#{comment.id}\">comment</a> in \"#{resource_title}\" has been #{verb}")
      expect(subject.notification_title)
        .to include("It now has a total of 999 upvotes and 100 downvotes.")
    end
  end
end
