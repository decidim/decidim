# frozen_string_literal: true

module Decidim
  module Budgets
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Budgets::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :project

        case permission_action.action
        when :report
          permission_action.allow!
        end

        permission_action
      end
    end
  end
end
