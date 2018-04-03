# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?

          return false if permission_action.scope != :admin

          false
        end
      end
    end
  end
end
