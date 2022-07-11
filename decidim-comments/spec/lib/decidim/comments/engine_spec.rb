# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Engine do
  describe "decidim_comments.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:component, organization: organization) }
    let(:commentable) { build(:dummy_resource, component: component) }
    let(:votable_comments) { create_list(:comment, 5, commentable: commentable) }
    let(:original_records) do
      {
        comments: create_list(:comment, 3, commentable: commentable, author: original_user),
        votes: votable_comments.map { |comment| create(:comment_vote, comment: comment, author: original_user) }
      }
    end
    let(:transferred_comments) { Decidim::Comments::Comment.where(author: target_user).order(:id) }
    let(:transferred_comment_votes) { Decidim::Comments::CommentVote.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_comments.count).to eq(3)
      expect(transferred_comment_votes.count).to eq(5)
      expect(transfer.records.count).to eq(8)
      expect(transferred_resources).to eq(transferred_comments + transferred_comment_votes)
    end
  end
end
