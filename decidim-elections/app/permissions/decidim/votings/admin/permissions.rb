# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          user_can_enter_space_area?

          case permission_action.subject
          when :votings
            toggle_allow(user.admin?) if permission_action.action == :read
          when :voting
            case permission_action.action
            when :read, :create, :update
              toggle_allow(user.admin?)
            end
          end
          permission_action
        end

        private

        def user_can_enter_space_area?
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :votings

          allow!
        end

        def voting
          @voting ||= context.fetch(:voting, nil)
        end
      end
    end
  end
end
