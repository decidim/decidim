# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentVotedEvent do
  include_context "when it's a comment event"

  let(:event_name) { "decidim.events.comments.comment_voted" }

  let(:resource) { comment.commentable }

  let(:comment) { create :comment }
  let(:comment_vote) { create :comment_vote, comment: comment }
  let(:comment_vote_author) { comment_vote.author }
  let(:comment_author) { comment.author }

  let(:extra) { { comment_id: comment.id, author_id: comment_vote_author.id, weight: weight } }
  let(:weight) { 1 }
  let(:resource_title) { decidim_html_escape(translated(resource.title)) }
  let(:resource_text) { subject.resource_text }

  it_behaves_like "a simple event"

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
      expect(subject.email_subject).to eq("#{comment_vote_author.name} voted your comment in #{resource_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("Your comment in #{resource_title} has been voted by #{comment_vote_author.name}.")
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
        .to include("voted your <a href=\"#{resource_path}#comment_#{comment.id}\">comment</a> in #{resource_title}")
    end
  end

  describe "upvote?" do
    context "when weight is positive" do
      let(:weight) { 1 }
      it "returns true" do
        expect(subject.upvote?).to eq(true)
      end
    end

    context "when weight is negative" do
      let(:weight) { -1 }
      it "returns false" do
        expect(subject.upvote?).to eq(false)
      end
    end
  end
end
