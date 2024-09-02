# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Shared behaviour for commentable models.
    module Commentable
      extend ActiveSupport::Concern

      included do
        has_many :comment_threads, as: :root_commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", class_name: "Decidim::Comments::Comment"
        has_many :comments, as: :commentable, foreign_key: "decidim_root_commentable_id", foreign_type: "decidim_root_commentable_type", class_name: "Decidim::Comments::Comment"

        # Public: Whether the object's comments are visible or not.
        def commentable?
          true
        end

        # Public: Whether the object can have new comments or not.
        def accepts_new_comments?
          true
        end

        # Public: Whether the object's comments can have alignment or not. It enables the
        # alignment selector in the add new comment form.
        def comments_have_alignment?
          false
        end

        # Public: Whether the object's comments can have votes or not. It enables the
        # upvote and downvote buttons for comments.
        def comments_have_votes?
          false
        end

        # Public: Identifies the commentable type in the API.
        def commentable_type
          self.class.name
        end

        # Public: Defines which users will receive a notification when a comment is created.
        # This method can be overridden at each resource model to include or exclude
        # other users, eg. admins.
        # Returns: a relation of Decidim::User objects.
        def users_to_notify_on_comment_created
          Decidim::User.none
        end

        # Public: Whether the object can have new comments or not.
        def user_allowed_to_comment?(_user)
          true
        end

        # Public: Whether the object can have new comment votes or not.
        def user_allowed_to_vote_comment?(_user)
          true
        end

        # Public: Updates the comments counter cache. We have to do it these
        # way in order to properly calculate the counter with hidden
        # comments.
        #
        # rubocop:disable Rails/SkipsModelValidations
        def update_comments_count
          comments_count = comments.not_hidden.not_deleted.count
          update_columns(comments_count:, updated_at: Time.current)
        end
        # rubocop:enable Rails/SkipsModelValidations

        # Public: Returns an array with extra actions available for a comment and a user.
        # Returns an array of hashes with the following keys:
        #   - label: The label to be displayed in the UI.
        #   - url: The action to be performed when the user clicks the label.
        #   - method: The HTTP method to be used when performing the action (optional).
        #   - icon: The icon to be displayed next to the label (optional).
        #   - data: Any "data-*" attributes to be included in the link (optional).
        def actions_for_comment(_comment, _current_user)
          []
        end
      end
    end
  end
end
