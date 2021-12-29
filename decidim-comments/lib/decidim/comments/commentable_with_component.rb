# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Commentable overriding some methods to include settings and
    # authorizations given by a component the resource belongs to
    module CommentableWithComponent
      extend ActiveSupport::Concern
      include Decidim::Comments::Commentable

      included do
        # Public: Overrides the `commentable?` Commentable concern method.
        def commentable?
          component.settings.comments_enabled?
        end

        # Public: Overrides the `accepts_new_comments?` Commentable concern method.
        def accepts_new_comments?
          commentable? && !component.current_settings.comments_blocked
        end

        # Public: Whether the object can have new comments or not.
        def user_allowed_to_comment?(user)
          return unless can_participate?(user)

          ActionAuthorizer.new(user, "comment", component, self).authorize.ok?
        end
      end
    end
  end
end
