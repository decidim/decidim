# frozen_string_literal: true

module Decidim
  module Comments
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if permission_action.subject != :comment

        case permission_action.action
        when :read
          can_read_comments?
        when :create
          can_create_comment?
        when :update, :destroy
          can_update_comment?
        when :vote
          can_vote_comment?
        end

        permission_action
      end

      private

      def can_read_comments?
        return disallow! unless commentable.commentable?

        allow!
      end

      def can_create_comment?
        return disallow! unless user
        return disallow! unless commentable.commentable?
        return disallow! unless commentable&.user_allowed_to_comment?(user)

        allow!
      end

      def can_update_comment?
        return disallow! unless user
        return disallow! unless comment.authored_by?(user)

        allow!
      end

      def can_vote_comment?
        return disallow! unless user
        return disallow! unless commentable&.user_allowed_to_vote_comment?(user)

        allow!
      end

      def commentable
        @commentable ||= if comment
                           comment.root_commentable
                         else
                           context.fetch(:commentable, nil)
                         end
      end

      def comment
        @comment ||= context.fetch(:comment, nil)
      end
    end
  end
end
