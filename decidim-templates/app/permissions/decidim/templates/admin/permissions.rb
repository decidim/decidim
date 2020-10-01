# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :template
            allow! if [:read, :create, :update, :destroy, :copy].include? permission_action.action
          when :templates
            allow! if permission_action.action == :index
          when :questionnaire
            allow!
          end

          permission_action
        end
      end
    end
  end
end
