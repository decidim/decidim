# frozen_string_literal: true

module Decidim
  class UserManagerPermissions < DefaultPermissions
    def permissions
      if user_manager?
        allow! if read_admin_dashboard_action?
        allow! if impersonate_managed_user_action?
      end

      permission_action
    end

    private

    def read_admin_dashboard_action?
      permission_action.subject == :admin_dashboard &&
        permission_action.action == :read
    end

    def impersonate_managed_user_action?
      permission_action.subject == :managed_user &&
        permission_action.action == :impersonate
    end

    # Whether the user has the user_manager role or not.
    def user_manager?
      user && !user.admin? && user.role?("user_manager")
    end
  end
end
