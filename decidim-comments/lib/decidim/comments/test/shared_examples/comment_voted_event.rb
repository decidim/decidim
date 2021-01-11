# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a comment voted event" do
  include_context "when it's a comment event"
  # it_behaves_like "a simple event"

  let(:resource) { comment.commentable }

  let(:comment) { create :comment }
  let(:comment_vote) { create :comment_vote, comment: comment }
  let(:comment_vote_author) { comment_vote.author }
  let(:comment_author) { comment.author }

  let(:extra) { { comment_id: comment.id, author_id: comment_vote_author.id, weight: weight } }
  let(:resource_title) { decidim_html_escape(translated(resource.title)) }
  let(:resource_text) { subject.resource_text }

  let(:verb) { weight.positive? ? "upvoted" : "downvoted" }

  describe "author" do
    it "returns the comment vote author" do
      expect(subject.author).to eq(comment_vote_author)
    end
  end

  describe "resource_text" do
    it "outputs the comment body" do
      expect(subject.resource_text).to eq comment.formatted_body
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("#{comment_vote_author.name} #{verb} your comment in #{resource_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("Your comment in #{resource_title} has been #{verb} by #{comment_vote_author.name}.")
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
        .to include("<a href=\"/profiles/#{comment_vote_author.nickname}\">#{comment_vote_author.name} @#{comment_vote_author.nickname}</a>")

      expect(subject.notification_title)
        .to include("#{verb} your <a href=\"#{resource_path}#comment_#{comment.id}\">comment</a> in #{resource_title}")
    end
  end
end
