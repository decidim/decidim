# frozen_string_literal: true

module Decidim
  module Surveys
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        return Decidim::Surveys::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :survey

        permission_action.allow! if permission_action.action == :answer

        permission_action
      end
    end
  end
end
