# frozen_string_literal: true

module Decidim
  module Pages
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?

        return false if permission_action.scope != :admin

        return true if permission_action.action == :update

        false
      end
    end
  end
end
