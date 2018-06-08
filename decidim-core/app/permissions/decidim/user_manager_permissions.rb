# frozen_string_literal: true

module Decidim
  class UserManagerPermissions < DefaultPermissions
    def permissions
      allow! if read_admin_dashboard_action?
      allow! if impersonate_managed_user_action?

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
  end
end
