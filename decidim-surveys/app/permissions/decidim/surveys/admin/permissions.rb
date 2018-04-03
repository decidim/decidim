# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?
          return false unless user

          return false if permission_action.scope != :admin

          return false if permission_action.subject != :survey

          return true if case permission_action.action
                         when :export_answers, :update
                           true
                         else
                           false
                         end

          false
        end
      end
    end
  end
end
