# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?

          # The public part needs to be implemented yet
          return false if permission_action.scope != :admin
          return false if permission_action.subject != :debate

          return true if case permission_action.action
                         when :create
                           true
                         when :update, :delete
                           debate && debate.official?
                         else
                           false
                         end

          false
        end

        private

        def debate
          @debate ||= context.fetch(:debate, nil)
        end
      end
    end
  end
end
