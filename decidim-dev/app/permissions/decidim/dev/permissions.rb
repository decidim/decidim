# frozen_string_literal: true

module Decidim
  module Dev
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        return permission_action if permission_action.scope != :public

        toggle_allow(!dummy_resource.hidden? && dummy_resource.published?) if permission_action.subject == :dummy_resource
        permission_action
      end

      private

      def dummy_resource
        context[:dummy_resource] = context.fetch(:dummy_resource, nil) || context.fetch(:resource, nil)
      end
    end
  end
end
