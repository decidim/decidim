# frozen_string_literal: true

module Decidim
  module Debates
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Debates::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :debate

        case permission_action.action
        when :create
          toggle_allow(can_create_debate?)
        when :report
          allow!
        end

        permission_action
      end

      private

      def can_create_debate?
        authorized?(:create) &&
          current_settings&.creation_enabled?
      end
    end
  end
end
