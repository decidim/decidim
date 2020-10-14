# frozen_string_literal: true

module Decidim
  module Comments
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if permission_action.subject != :comment

        case permission_action.action
        when :create
          can_create_comment?
        end

        permission_action
      end

      private

      def can_create_comment?
        return disallow! unless user
        return allow! if commentable&.user_allowed_to_comment?(user)

        disallow!
      end

      def commentable
        @commentable ||= context.fetch(:commentable, nil)
      end
    end
  end
end
