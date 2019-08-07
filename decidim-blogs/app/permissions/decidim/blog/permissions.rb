# frozen_string_literal: true

module Decidim
  module Blog
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless permission_action.subject == :blogpost

        if permission_action.scope == :public
          allow!
          return permission_action
        end

        return permission_action if permission_action.scope != :admin

        allow!
        permission_action
      end
    end
  end
end
