# frozen_string_literal: true

module Decidim
  class ReportUserPermissions < DefaultPermissions
    def permissions
      return permission_action unless user

      allow! if permission_action.subject == :user_report && permission_action.action == :create

      permission_action
    end
  end
end
