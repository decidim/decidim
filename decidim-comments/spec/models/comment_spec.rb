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
    end
  end
end
