# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let!(:commentable) { create(:participatory_process) }
      let!(:comment) { create(:comment, commentable: commentable) }
      let!(:replies) { 3.times.map { create(:comment, commentable: comment) } }

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
    end
  end
end
