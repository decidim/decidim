# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::CollaborativeTexts::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :collaborative_text

        case permission_action.action
        when :suggest
          allow! if user
        when :rollout
          allow! if user && user.admin? # TODO: allow participatory space admins!
        end

        permission_action
      end

      private

      def document
        @document ||= context.fetch(:document, nil) || context.fetch(:resource, nil)
      end
    end
  end
end
