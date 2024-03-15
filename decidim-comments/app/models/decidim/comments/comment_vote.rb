# frozen_string_literal: true

module Decidim
  module Comments
    # A comment can include user votes. A user should be able to upVote, votes with
    # weight 1 and downVote, votes with weight -1.
    class CommentVote < ApplicationRecord
      include Decidim::DownloadYourData

      belongs_to :comment, foreign_key: "decidim_comment_id", class_name: "Comment"
      belongs_to :author, foreign_key: "decidim_author_id", foreign_type: "decidim_author_type", polymorphic: true

      validates :comment, uniqueness: { scope: :author }
      validates :weight, inclusion: { in: [-1, 1] }
      validate :author_and_comment_same_organization

      after_create :update_comment_votes_count
      after_destroy :update_comment_votes_count

      def self.export_serializer
        Decidim::Comments::CommentVoteSerializer
      end

      private

      def update_comment_votes_count
        up_votes_count = self.class.where(decidim_comment_id: comment.id, weight: 1).count
        down_votes_count = self.class.where(decidim_comment_id: comment.id, weight: -1).count

        comment.update(up_votes_count:, down_votes_count:)
      end

      # Private: check if the comment and the author have the same organization
      def author_and_comment_same_organization
        return unless author.present? && comment.present?

        errors.add(:comment, :invalid) unless author.organization == comment.organization
      end
    end
  end
end
