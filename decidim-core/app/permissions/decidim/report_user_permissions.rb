# frozen_string_literal: true

module Decidim
  class ReportUserPermissions < DefaultPermissions
    def permissions
      return permission_action unless user
      allow!

      permission_action
    end
  end
end
