# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?
          return false unless user

          return false if permission_action.scope != :admin

          return false if permission_action.subject != :sortition

          return true if case permission_action.action
                         when :destroy
                           sortition.present? && !sortition.cancelled?
                         when :update
                           sortition.present?
                         when :create, :read
                           true
                         else
                           false
                         end

          false
        end

        private

        def sortition
          @sortition ||= context.fetch(:sortition, nil)
        end
      end
    end
  end
end
