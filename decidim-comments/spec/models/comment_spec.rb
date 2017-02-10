# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let!(:commentable) { create(:dummy_resource) }
      let!(:comment) { create(:comment, commentable: commentable) }
      let!(:replies) { 3.times.map { create(:comment, commentable: comment) } }
      let!(:up_vote) { create(:comment_vote, :up_vote, comment: comment) }
      let!(:down_vote) { create(:comment_vote, :down_vote, comment: comment) }

      subject { comment }

      include_examples "authorable"

      it "is valid" do
        expect(subject).to be_valid
      end

      it "has an associated commentable" do
        expect(subject.commentable).to eq(commentable)
      end

      it "has a up_votes association returning comment votes with weight 1" do
        expect(subject.up_votes.count).to eq(1)
      end

      it "has a down_votes association returning comment votes with weight -1" do
        expect(subject.down_votes.count).to eq(1)
      end

      it "is not valid if its parent is a comment and cannot have comments" do
        expect(subject).to receive(:commentable?).and_return false
        expect(replies[0]).not_to be_valid
      end

      it "should compute its depth before saving the model" do
        expect(subject.depth).to eq(0)
        comment.comments.each do |reply|
          expect(reply.depth).to eq(1)
        end
      end

      describe "#commentable?" do
        it "should return true if the comment's depth is below MAX_DEPTH" do
          subject.depth = Comment::MAX_DEPTH - 1
          expect(subject).to be_commentable
        end

        it "should return false if the comment's depth is equal or greater than MAX_DEPTH" do
          subject.depth = Comment::MAX_DEPTH
          expect(subject).not_to be_commentable
        end
      end

      it "is not valid if alignment is not 0, 1 or -1" do
        subject.alignment = 2
        expect(subject).not_to be_valid
      end

      describe "#up_voted_by?" do
        let(:user) { create(:user, organization: subject.organization) }
        it "should return true if the given user has upvoted the comment" do
          create(:comment_vote, comment: subject, author: user, weight: 1)
          expect(subject.up_voted_by?(user)).to be_truthy
        end

        it "should return false if the given user has not upvoted the comment" do
          expect(subject.up_voted_by?(user)).to be_falsy
        end
      end

      describe "#down_voted_by?" do
        let(:user) { create(:user, organization: subject.organization) }
        it "should return true if the given user has downvoted the comment" do
          create(:comment_vote, comment: subject, author: user, weight: -1)
          expect(subject.down_voted_by?(user)).to be_truthy
        end

        it "should return false if the given user has not downvoted the comment" do
          expect(subject.down_voted_by?(user)).to be_falsy
        end
      end

      describe "#root_commentable" do
        let(:reply) { create(:comment, commentable: subject) }

        it "returns the commentable object from the parent comment" do
          expect(reply.root_commentable).to eq(subject.commentable)
        end
      end
    end
  end
end
