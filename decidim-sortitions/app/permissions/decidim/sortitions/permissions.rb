# frozen_string_literal: true

module Decidim
  module Sortitions
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return Decidim::Sortitions::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        allow! if permission_action.subject == :sortition && permission_action.action == :read

        permission_action
      end
    end
  end
end
