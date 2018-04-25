# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          permission_action
        end

        private

        def user_can_enter_space_area?
          return unless user
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :initiatives

          toggle_allow(user.admin? || has_initiatives?)
        end

        def has_initiatives?
          (InitiativesCreated.by(user) | InitiativesPromoted.by(user)).any?
        end

      end
    end
  end
end
