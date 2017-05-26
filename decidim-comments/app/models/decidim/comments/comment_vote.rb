# frozen_string_literal: true

module Decidim
  module Comments
    # A comment can include user votes. A user should be able to upVote, votes with
    # weight 1 and downVote, votes with weight -1.
    class CommentVote < ApplicationRecord
      belongs_to :comment, foreign_key: "decidim_comment_id", class_name: "Comment"
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      validates :comment, presence: true, uniqueness: { scope: :author }
      validates :author, presence: true
      validates :weight, inclusion: { in: [-1, 1] }
      validate :author_and_comment_same_organization

      private

      # Private: check if the comment and the author have the same organization
      def author_and_comment_same_organization
        return unless author.present? && comment.present?
        errors.add(:comment, :invalid) unless author.organization == comment.organization
      end
    end
  end
end
