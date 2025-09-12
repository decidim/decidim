# frozen_string_literal: true

module Decidim
  module Accountability
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if permission_action.scope == :public && public_read_result_action?
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Accountability::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        permission_action
      end

      private

      def public_read_result_action?
        return unless permission_action.action == :read && permission_action.subject == :result

        if result && !result.deleted?
          allow!
        else
          disallow!
        end
      end

      def result
        @result ||= context.fetch(:result, nil)
      end
    end
  end
end
