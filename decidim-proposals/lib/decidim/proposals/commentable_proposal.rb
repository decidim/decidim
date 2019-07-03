# frozen_string_literal: true

module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    module CommentableProposal
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

        # Public: Overrides the `comments_have_alignment?` Commentable concern method.
        def comments_have_alignment?
          true
        end

        # Public: Overrides the `comments_have_votes?` Commentable concern method.
        def comments_have_votes?
          true
        end

        # Public: Override Commentable concern method `users_to_notify_on_comment_created`
        def users_to_notify_on_comment_created
          return (followers | component.participatory_space.admins).uniq if official?

          followers
        end

        def user_allowed_to_comment?(user)
          can_participate_in_space?(user)
        end
      end
    end
  end
end
