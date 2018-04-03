# frozen_string_literal: true

module Decidim
  module Accountability
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?
        return false unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Accountability::Admin::Permissions.new(user, permission_action, context).allowed? if permission_action.scope == :admin

        false
      end
    end
  end
end
