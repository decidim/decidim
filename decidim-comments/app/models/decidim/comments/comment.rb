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
      include Decidim::DownloadYourData
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::ActsAsTree
      include ActionView::Helpers::TextHelper

      # Limit the max depth of a comment tree. If C is a comment and R is a reply:
      # C          (depth 0)
      # |--R       (depth 1)
      # |--R       (depth 1)
      #    |--R    (depth 2)
      #       |--R (depth 3)
      MAX_DEPTH = 3

      translatable_fields :body

      parent_item_foreign_key :decidim_commentable_id
      parent_item_polymorphic_type_key :decidim_commentable_type

      belongs_to :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", polymorphic: true
      belongs_to :root_commentable, foreign_key: "decidim_root_commentable_id", foreign_type: "decidim_root_commentable_type", polymorphic: true, touch: true
      belongs_to :participatory_space, foreign_key: "decidim_participatory_space_id", foreign_type: "decidim_participatory_space_type", polymorphic: true, optional: true
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

      scope :not_deleted, -> { where(deleted_at: nil) }

      translatable_fields :body
      searchable_fields({
                          participatory_space: :itself,
                          A: :body,
                          datetime: :created_at
                        },
                        index_on_create: true,
                        index_on_update: ->(comment) { comment.visible? })

      def self.positive
        where(alignment: 1)
      end

      def self.neutral
        where(alignment: 0)
      end

      def self.negative
        where(alignment: -1)
      end

      def reported_title
        truncate(translated_attribute(body))
      end

      def organization
        commentable&.organization || participatory_space&.organization
      end

      def visible?
        participatory_space.try(:visible?) && component.try(:published?)
      end

      alias original_participatory_space participatory_space

      def participatory_space
        return original_participatory_space if original_participatory_space.present?
        return root_commentable unless root_commentable.respond_to?(:participatory_space)

        root_commentable.participatory_space
      end

      def component
        commentable.component if commentable.respond_to?(:component)
      end

      # Public: Override Commentable concern method `accepts_new_comments?`
      def accepts_new_comments?
        return if deleted?

        root_commentable.accepts_new_comments? && depth < MAX_DEPTH
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
        up_votes.exists?(author: user)
      end

      # Public: Check if the user has downvoted the comment
      #
      # Returns a bool value to indicate if the condition is truthy or not
      def down_voted_by?(user)
        down_votes.exists?(author: user)
      end

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        return unless root_commentable

        url_params = { anchor: "comment_#{id}" }

        if root_commentable.respond_to?(:polymorphic_resource_url)
          root_commentable.polymorphic_resource_url(url_params)
        else
          root_commentable.reported_content_url(url_params)
        end
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:body]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [normalized_author.name]
      end

      def self.export_serializer
        Decidim::Comments::CommentSerializer
      end

      # Public: Returns the list of author IDs of type `UserBaseEntity` that commented in one of the +resources+.
      # Expects all +resources+ to be of the same "commentable_type".
      # If the result is not `Decidim::Comments::Commentable` returns `nil`.
      def self.user_commentators_ids_in(resources)
        if resources.first.is_a?(Decidim::Comments::Commentable)
          commentable_type = resources.first.class.name
          Decidim::Comments::Comment.select("DISTINCT decidim_author_id").not_hidden.not_deleted
                                    .where(decidim_commentable_id: resources.pluck(:id))
                                    .where(decidim_commentable_type: commentable_type)
                                    .where("decidim_author_type" => "Decidim::UserBaseEntity").pluck(:decidim_author_id)
        else
          []
        end
      end

      def can_participate?(user)
        return true unless root_commentable.respond_to?(:can_participate?)

        root_commentable.can_participate?(user)
      end

      # The override_translation argument has been added to be able to use this
      # method from comment event in the resource_text method which requires
      # the use of this argument in translated_attribute of body
      def formatted_body(override_translation = nil)
        Decidim::ContentProcessor.render(sanitize_content_for_comment(render_markdown(translated_body(override_translation))), "div")
      end

      def translated_body(override_translation = nil)
        translated_attribute(body, organization, override_translation)
      end

      def delete!
        return if deleted?

        update(deleted_at: Time.current)

        update_counter
      end

      def deleted?
        deleted_at.present?
      end

      def edited?
        Decidim::ActionLog.where(resource: self).exists?(["extra @> ?", Arel.sql("{\"edit\":true}")])
      end

      def extra_actions_for(current_user)
        root_commentable.try(:actions_for_comment, self, current_user)
      end

      private

      def body_length
        language = (body.keys - ["machine_translations"]).first
        errors.add(:body, :too_long, count: comment_maximum_length) unless body[language].length <= comment_maximum_length
      end

      def comment_maximum_length
        return 0 unless commentable.commentable?
        return component.settings.comments_max_length if component_settings_comments_max_length?
        return organization.comments_max_length if organization.comments_max_length.positive?

        1000
      end

      def component_settings_comments_max_length?
        return unless component&.settings.respond_to?(:comments_max_length)

        component.settings.comments_max_length.positive?
      end

      # Private: Compute comment depth inside the current comment tree
      def compute_depth
        self.depth = commentable.depth + 1 if commentable.respond_to?(:depth)
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

      def sanitize_content_for_comment(text, options = {})
        Rails::Html::WhiteListSanitizer.new.sanitize(
          text,
          { scrubber: Decidim::Comments::UserInputScrubber.new }.merge(options)
        ).try(:html_safe)
      end
    end
  end
end
