# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let!(:commentable) { create(:dummy_resource) }
      let!(:author) { create(:user, organization: commentable.organization) }
      let!(:comment) { create(:comment, commentable: commentable, author: author) }
      let!(:replies) { create_list(:comment, 3, commentable: comment, root_commentable: commentable) }
      let!(:up_vote) { create(:comment_vote, :up_vote, comment: comment) }
      let!(:down_vote) { create(:comment_vote, :down_vote, comment: comment) }

      include_examples "authorable" do
        subject { comment }
      end

      include_examples "reportable" do
        subject { comment }
      end

      it "is valid" do
        expect(comment).to be_valid
      end

      it "has an associated commentable" do
        expect(comment.commentable).to eq(commentable)
      end

      it "has an associated root commentable" do
        expect(comment.root_commentable).to eq(commentable)
      end

      it "has a up_votes association returning comment votes with weight 1" do
        expect(comment.up_votes.count).to eq(1)
      end

      it "has a down_votes association returning comment votes with weight -1" do
        expect(comment.down_votes.count).to eq(1)
      end

      it "is not valid if its parent is a comment and cannot accept new comments" do
        expect(comment.root_commentable).to receive(:accepts_new_comments?).and_return false
        expect(replies[0]).not_to be_valid
      end

      it "computes its depth before saving the model" do
        expect(comment.depth).to eq(0)
        comment.comments.each do |reply|
          expect(reply.depth).to eq(1)
        end
      end

      describe "#accepts_new_comments?" do
        it "returns true if the comment's depth is below MAX_DEPTH" do
          comment.depth = Comment::MAX_DEPTH - 1
          expect(comment).to be_accepts_new_comments
        end

        it "returns false if the comment's depth is equal or greater than MAX_DEPTH" do
          comment.depth = Comment::MAX_DEPTH
          expect(comment).not_to be_accepts_new_comments
        end
      end

      it "is not valid if alignment is not 0, 1 or -1" do
        comment.alignment = 2
        expect(comment).not_to be_valid
      end

      describe "#up_voted_by?" do
        let(:user) { create(:user, organization: comment.organization) }

        it "returns true if the given user has upvoted the comment" do
          create(:comment_vote, comment: comment, author: user, weight: 1)
          expect(comment).to be_up_voted_by(user)
        end

        it "returns false if the given user has not upvoted the comment" do
          expect(comment).not_to be_up_voted_by(user)
        end
      end

      describe "#down_voted_by?" do
        let(:user) { create(:user, organization: comment.organization) }

        it "returns true if the given user has downvoted the comment" do
          create(:comment_vote, comment: comment, author: user, weight: -1)
          expect(comment).to be_down_voted_by(user)
        end

        it "returns false if the given user has not downvoted the comment" do
          expect(comment).not_to be_down_voted_by(user)
        end
      end

      describe "#users_to_notify_on_comment_created" do
        let(:user) { create :user, organization: comment.organization }

        it "includes the comment author" do
          expect(comment.users_to_notify_on_comment_created)
            .to include(author)
        end

        it "includes the values from its commentable" do
          allow(comment.commentable)
            .to receive(:users_to_notify_on_comment_created)
            .and_return(Decidim::User.where(id: user.id))

          expect(comment.users_to_notify_on_comment_created)
            .to include(user)
        end
      end

      describe "#formatted_body" do
        let(:comment) { create(:comment, commentable: commentable, author: author, body: "<b>bold text</b> *lorem* <a href='https://example.com'>link</a>") }

        before do
          allow(Decidim).to receive(:content_processors).and_return([:dummy_foo])
        end

        it "sanitizes user input" do
          expect(comment).to receive(:sanitized_body)
          comment.formatted_body
        end

        it "process the body after it is sanitized" do
          expect(Decidim::ContentProcessor).to receive(:render).with("bold text *lorem* link")
          comment.formatted_body
        end

        it "returns the body sanitized and processed" do
          expect(comment.formatted_body).to eq("<p>bold text <em>neque dicta enim quasi</em> link</p>")
        end
      end
    end
  end
end
