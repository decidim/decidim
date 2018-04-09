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
            permission_action.allow!
          when :update, :delete
            permission_action.allow! if debate && debate.official?
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
