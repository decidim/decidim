# frozen_string_literal: true
module Decidim
  module Comments
    # Some resources will be configured as commentable objects so users can
    # comment on them. The will be able to create conversations between users
    # to discuss or share their thoughts about the resource.
    class Comment < ApplicationRecord
      # Limit the max depth of a comment tree. If C is a comment and R is a reply:
      # C          (depth 0)
      # |--R       (depth 1)
      # |--R       (depth 1)
      #    |--R    (depth 2)
      #       |--R (depth 3)
      MAX_DEPTH = 3

      belongs_to :author, class_name: Decidim::User
      belongs_to :commentable, polymorphic: true
      has_many :replies, as: :commentable, class_name: Comment

      validates :author, :commentable, :body, presence: true
      validate :commentable_can_have_replies

      before_save :compute_depth

      # Public: Define if a comment can have replies or not
      #
      # Returns a bool value to indicate if comment can have replies
      def can_have_replies?
        depth < MAX_DEPTH
      end

      private

      # Private: Check if commentable can have replies and if not adds
      # a validation error to the model
      def commentable_can_have_replies
        errors.add(:commentable, "can't have replies") if commentable.respond_to?(:can_have_replies?) && !commentable.can_have_replies?
      end

      # Private: Compute comment depth inside the current comment tree
      def compute_depth
        self.depth = commentable.depth + 1 if commentable.respond_to?(:depth)
      end
    end
  end
end
