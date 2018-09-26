# frozen_string_literal: true

module Decidim
  module Comments
    # Some resources will be configured as commentable objects so users can
    # comment on them. The will be able to create conversations between users
    # to discuss or share their thoughts about the resource.
    class Comment < ApplicationRecord
      include Decidim::Reportable
      include Decidim::Authorable
      include Decidim::Comments::Commentable
      include Decidim::FriendlyDates
      include Decidim::DataPortability

      # Limit the max depth of a comment tree. If C is a comment and R is a reply:
      # C          (depth 0)
      # |--R       (depth 1)
      # |--R       (depth 1)
      #    |--R    (depth 2)
      #       |--R (depth 3)
      MAX_DEPTH = 3

      belongs_to :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", polymorphic: true
      belongs_to :root_commentable, foreign_key: "decidim_root_commentable_id", foreign_type: "decidim_root_commentable_type", polymorphic: true
      has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_comment_id", class_name: "CommentVote", dependent: :destroy
      has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_comment_id", class_name: "CommentVote", dependent: :destroy

      validates :body, presence: true
      validates :depth, numericality: { greater_than_or_equal_to: 0 }
      validates :alignment, inclusion: { in: [0, 1, -1] }

      validates :body, length: { maximum: 1000 }

      validate :commentable_can_have_comments

      before_save :compute_depth

      delegate :organization, to: :commentable

      def participatory_space
        return root_commentable if root_commentable.is_a?(Decidim::Participable)
        root_commentable.participatory_space
      end

      def component
        commentable.component if commentable.respond_to?(:component)
      end

      # Public: Override Commentable concern method `accepts_new_comments?`
      def accepts_new_comments?
        depth < MAX_DEPTH
      end

      # Public: Override Commentable concern method `users_to_notify_on_comment_created`.
      # Return the comment author together with whatever ActiveRecord::Relation is returned by
      # the `commentable`. This will cause the comment author to be notified when the
      # comment is replied
      def users_to_notify_on_comment_created
        Decidim::User.where(id: commentable.users_to_notify_on_comment_created).or(
          Decidim::User.where(id: decidim_author_id)
        )
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

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(root_commentable).url(anchor: "comment_#{id}")
      end

      # Public: Returns the comment message ready to display (it is expected to include HTML)
      def formatted_body
        @formatted_body ||= Decidim::ContentProcessor.render(sanitized_body)
      end

      def self.export_serializer
        Decidim::Comments::CommentSerializer
      end

      private

      # Private: Check if commentable can have comments and if not adds
      # a validation error to the model
      def commentable_can_have_comments
        errors.add(:commentable, :cannot_have_comments) unless commentable.accepts_new_comments?
      end

      # Private: Compute comment depth inside the current comment tree
      def compute_depth
        self.depth = commentable.depth + 1 if commentable.respond_to?(:depth)
      end

      # Private: Returns the comment body sanitized, stripping HTML tags
      def sanitized_body
        Rails::Html::Sanitizer.full_sanitizer.new.sanitize(body)
      end
    end
  end
end
