# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let(:commentable) { build(:participatory_process) }
      let(:comment) { build(:comment, commentable: commentable) }

      it "is valid" do
        expect(comment).to be_valid
      end

      it "has an associated author" do
        expect(comment.author).to be_a(Decidim::User)
      end

      it "has an associated commentable" do
        expect(comment.commentable).to be_a(Decidim::ParticipatoryProcess)
      end
    end
  end
end
