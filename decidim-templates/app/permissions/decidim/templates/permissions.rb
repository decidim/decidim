# frozen_string_literal: true

module Decidim
  module Templates
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user || context[:current_settings].allow_unregistered?

        return Decidim::Templates::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :template

        permission_action.allow! if permission_action.action == :preview

        permission_action
      end
    end
  end
end
