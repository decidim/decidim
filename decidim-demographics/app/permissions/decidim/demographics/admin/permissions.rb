# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          toggle_allow(user.admin?) if permission_action.subject == :demographics && permission_action.action == :update

          permission_action
        end
      end
    end
  end
end
