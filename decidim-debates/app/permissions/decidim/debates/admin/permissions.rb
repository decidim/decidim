# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin
          return permission_action if permission_action.subject != :debate

          case permission_action.action
          when :create, :read
            allow!
          when :update
            toggle_allow(debate && !debate.closed? && debate.official?)
          when :delete, :close
            toggle_allow(debate && debate.official?)
          end

          permission_action
        end

        private

        def debate
          @debate ||= context.fetch(:debate, nil)
        end
      end
    end
  end
end
