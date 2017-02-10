# frozen_string_literal: true
module Decidim
  module Comments
    # Some resources will be configured as commentable objects so users can
    # comment on them. The will be able to create conversations between users
    # to discuss or share their thoughts about the resource.
    class Comment < ApplicationRecord
      include Decidim::Authorable
      include Decidim::Comments::Commentable

      # Limit the max depth of a comment tree. If C is a comment and R is a reply:
      # C          (depth 0)
      # |--R       (depth 1)
      # |--R       (depth 1)
      #    |--R    (depth 2)
      #       |--R (depth 3)
      MAX_DEPTH = 3

      belongs_to :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", polymorphic: true
      has_many :replies, as: :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", class_name: Comment
      has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_comment_id", class_name: CommentVote, dependent: :destroy
      has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_comment_id", class_name: CommentVote, dependent: :destroy

      validates :author, :commentable, :body, presence: true
      validates :depth, numericality: { greater_than_or_equal_to: 0 }
      validates :alignment, inclusion: { in: [0, 1, -1] }

      validate :commentable_can_have_comments

      before_save :compute_depth

      delegate :organization, to: :commentable

      # Public: Override Commentable concern method `can_have_comments?`
      def can_have_comments?
        depth < MAX_DEPTH
      end

      # Public: Check if the user has upvoted the comment
      #
      # Returns a bool value to indicate if the condition is truthy or not
      def up_voted_by?(user)
        up_votes.any? { |vote| vote.author == user }
      end

      # Public: Check if the user has downvoted the comment
      #
      # Returns a bool value to indicate if the condition is truthy or not
      def down_voted_by?(user)
        down_votes.any? { |vote| vote.author == user }
      end

      # Public: Returns the commentable object of the parent comment
      def root_commentable
        return commentable if depth == 0
        commentable.root_commentable
      end

      private

      # Private: Check if commentable can have comments and if not adds
      # a validation error to the model
      def commentable_can_have_replies
        errors.add(:commentable, :cannot_have_comments) unless commentable.can_have_comments?
      end

      # Private: Compute comment depth inside the current comment tree
      def compute_depth
        self.depth = commentable.depth + 1 if commentable.respond_to?(:depth)
      end
    end
  end
end
