# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action if permission_action.subject != :election

          case permission_action.subject
          when :election
            case permission_action.action
            when :create, :read
              allow!
            when :update
              toggle_allow(election.present?)
            end
          end

          permission_action
        end

        private

        def election
          @election ||= context.fetch(:election, nil)
        end
      end
    end
  end
end
