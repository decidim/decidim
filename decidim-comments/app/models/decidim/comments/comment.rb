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
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes

      # Limit the max depth of a comment tree. If C is a comment and R is a reply:
      # C          (depth 0)
      # |--R       (depth 1)
      # |--R       (depth 1)
      #    |--R    (depth 2)
      #       |--R (depth 3)
      MAX_DEPTH = 3

      translatable_fields :body

      belongs_to :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", polymorphic: true
      belongs_to :root_commentable, foreign_key: "decidim_root_commentable_id", foreign_type: "decidim_root_commentable_type", polymorphic: true, touch: true
      has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_comment_id", class_name: "CommentVote", dependent: :destroy
      has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_comment_id", class_name: "CommentVote", dependent: :destroy

      # Updates the counter caches for the root_commentable when a comment is
      # created or updated.
      after_save :update_counter

      # Updates the counter caches for the root_commentable when a comment is
      # deleted.
      after_destroy :update_counter

      # Updates the counter caches for the root_commentable when a comment is
      # touched, which happens when a comment was reported and its moderation
      # is accepted and sets the comment as hidden.
      after_touch :update_counter

      before_validation :compute_depth
      validates :body, presence: true
      validates :depth, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_DEPTH }
      validates :alignment, inclusion: { in: [0, 1, -1] }
      validate :body_length
      validate :commentable_can_have_comments

      delegate :organization, to: :commentable

      translatable_fields :body
      searchable_fields(
        participatory_space: :itself,
        A: :body,
        datetime: :created_at
      )

      def self.positive
        where(alignment: 1)
      end

      def self.neutral
        where(alignment: 0)
      end

      def self.negative
        where(alignment: -1)
      end

      def participatory_space
        return root_commentable if root_commentable.is_a?(Decidim::Participable)

        root_commentable.participatory_space
      end

      def component
        commentable.component if commentable.respond_to?(:component)
      end

      # Public: Override Commentable concern method `accepts_new_comments?`
      def accepts_new_comments?
        root_commentable.accepts_new_comments? && depth < MAX_DEPTH
      end

      # Public: Override comment threads to exclude hidden ones.
      #
      # Returns comment.
      def comment_threads
        super.reject(&:hidden?)
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
        url_params = { anchor: "comment_#{id}" }

        if root_commentable&.respond_to?(:polymorphic_resource_url)
          root_commentable.polymorphic_resource_url(url_params)
        else
          ResourceLocatorPresenter.new(root_commentable).url(url_params)
        end
      end

      def self.export_serializer
        Decidim::Comments::CommentSerializer
      end

      def self.newsletter_participant_ids(space)
        authors_sql = Decidim::Comments::Comment.select("DISTINCT decidim_comments_comments.decidim_author_id").not_hidden
                                                .where("decidim_comments_comments.decidim_author_type" => "Decidim::UserBaseEntity").to_sql

        Decidim::User.where(organization: space.organization).where("id IN (#{authors_sql})").pluck(:id)
      end

      def can_participate?(user)
        return true unless root_commentable&.respond_to?(:can_participate?)

        root_commentable.can_participate?(user)
      end

      def formatted_body
        Decidim::ContentProcessor.render(sanitize_content(render_markdown(translated_body)), "div")
      end

      def translated_body
        @translated_body ||= translated_attribute(body, organization)
      end

      private

      def body_length
        errors.add(:body, :too_long, count: comment_maximum_length) unless body.length <= comment_maximum_length
      end

      def comment_maximum_length
        return unless commentable.commentable?
        return component.settings.comments_max_length if component_settings_comments_max_length?
        return organization.comments_max_length if organization.comments_max_length.positive?

        1000
      end

      def component_settings_comments_max_length?
        return unless component&.settings.respond_to?(:comments_max_length)

        component.settings.comments_max_length.positive?
      end

      # Private: Check if commentable can have comments and if not adds
      # a validation error to the model
      def commentable_can_have_comments
        errors.add(:commentable, :cannot_have_comments) unless root_commentable.accepts_new_comments?
      end

      # Private: Compute comment depth inside the current comment tree
      def compute_depth
        self.depth = commentable.depth + 1 if commentable.respond_to?(:depth)
      end

      # Private: Returns the comment body sanitized, sanitizing HTML tags
      def sanitize_content(content)
        Decidim::ContentProcessor.sanitize(content)
      end

      # Private: Initializes the Markdown parser
      def markdown
        @markdown ||= Decidim::Comments::Markdown.new
      end

      # Private: converts the string from markdown to html
      def render_markdown(string)
        markdown.render(string)
      end

      def update_counter
        return unless root_commentable

        root_commentable.update_comments_count
      end
    end
  end
end
