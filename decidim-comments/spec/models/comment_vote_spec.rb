# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentVote do
      let!(:organization) { create(:organization) }
      let!(:participatory_process) { create(:participatory_process, organization:) }
      let!(:component) { create(:component, participatory_space: participatory_process) }
      let!(:commentable) { create(:dummy_resource, component:) }
      let!(:author) { create(:user, organization:) }
      let!(:comment) { create(:comment, commentable:, author:) }
      let!(:comment_vote) { create(:comment_vote, comment:, author:) }

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
        expect do
          create(:comment_vote, comment:, author:)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "is invalid with a weight different from 1 and -1" do
        comment_vote.weight = 2
        expect(comment_vote).to be_invalid
      end

      it "is invalid if comment and author have different organizations" do
        author = create(:user)
        comment = create(:comment)
        comment_vote = build(:comment_vote, comment:, author:)
        expect(comment_vote).to be_invalid
      end
    end
  end
end
