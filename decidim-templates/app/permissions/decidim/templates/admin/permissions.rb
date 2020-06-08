# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

          if permission_action.subject == :template
            case permission_action.action
            when :read, :create, :update, :destroy
              allow!
            end
          elsif permission_action.subject == :templates
            allow! if permission_action.action == :index
          end

          permission_action
        end
      end
    end
  end
end
