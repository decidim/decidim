# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CommentVote do
      let!(:comment_vote) { create(:comment_vote) }

      it "is valid" do
        expect(comment_vote).to be_valid
      end

      it "has an associated author" do
        expect(comment_vote.author).to be_a(Decidim::User)
      end

      it "has an associated comment" do
        expect(comment_vote.comment).to be_a(Decidim::Comments::Comment)
      end

      it "validates uniqueness for author and comment combination" do
        author = create(:user)
        comment = create(:comment)
        create(:comment_vote, comment: comment, author: author)
        expect {
          create(:comment_vote, comment: comment, author: author)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
