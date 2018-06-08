# frozen_string_literal: true

module Decidim
  module Pages
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if permission_action.scope != :admin

        permission_action.allow! if permission_action.action == :update

        permission_action
      end
    end
  end
end
