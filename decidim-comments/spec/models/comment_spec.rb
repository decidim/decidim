# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let!(:commentable) { create(:participatory_process) }
      let!(:comment) { create(:comment, commentable: commentable) }
      let!(:replies) { 3.times.map { create(:comment, commentable: comment) } }
      let!(:up_vote) { create(:comment_vote, :up_vote, comment: comment) }
      let!(:down_vote) { create(:comment_vote, :down_vote, comment: comment) }

      it "is valid" do
        expect(comment).to be_valid
      end

      it "has an associated author" do
        expect(comment.author).to be_a(Decidim::User)
      end

      it "has an associated commentable" do
        expect(comment.commentable).to be_a(Decidim::ParticipatoryProcess)
      end

      it "has a replies association" do
        expect(comment.replies).to match_array(replies)
      end

      it "has a up_votes association returning comment votes with weight 1" do
        expect(comment.up_votes.count).to eq(1)
      end

      it "has a down_votes association returning comment votes with weight -1" do
        expect(comment.down_votes.count).to eq(1)
      end

      it "is not valid if its parent is a comment and cannot have replies" do
        expect(comment).to receive(:can_have_replies?).and_return false
        expect(replies[0]).not_to be_valid
      end

      it "should compute its depth before saving the model" do
        expect(comment.depth).to eq(0)
        comment.replies.each do |reply|
          expect(reply.depth).to eq(1)
        end
      end

      it "is not valid if the author organization is different" do
        foreign_user = build(:user)
        comment = build(:comment, author: foreign_user)

        expect(comment).to_not be_valid
      end

      describe "#can_have_replies?" do
        it "should return true if the comment's depth is below MAX_DEPTH" do
          comment.depth = Comment::MAX_DEPTH - 1
          expect(comment.can_have_replies?).to be_truthy
        end

        it "should return false if the comment's depth is equal or greater than MAX_DEPTH" do
          comment.depth = Comment::MAX_DEPTH
          expect(comment.can_have_replies?).to be_falsy          
        end
      end

      it "is not valid if alignment is not 0, 1 or -1" do
        comment.alignment = 2
        expect(comment).not_to be_valid
      end

      describe "#up_voted_by?" do
        let(:user) { create(:user) }
        it "should return true if the given user has upvoted the comment" do
          create(:comment_vote, comment: comment, author: user, weight: 1)
          expect(comment.up_voted_by?(user)).to be_truthy
        end

        it "should return false if the given user has not upvoted the comment" do
          expect(comment.up_voted_by?(user)).to be_falsy
        end
      end

      describe "#down_voted_by?" do
        let(:user) { create(:user) }
        it "should return true if the given user has downvoted the comment" do
          create(:comment_vote, comment: comment, author: user, weight: -1)
          expect(comment.down_voted_by?(user)).to be_truthy
        end

        it "should return false if the given user has not downvoted the comment" do
          expect(comment.down_voted_by?(user)).to be_falsy
        end
      end
    end
  end
end
