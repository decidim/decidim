# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action if context[:current_organization] != user.organization

          if user_has_a_role? && (permission_action.subject == :template && permission_action.action == :read)
            allow!
          else
            return permission_action unless user.admin?

            case permission_action.subject
            when :template
              allow! if [:read, :create, :update, :destroy, :copy].include? permission_action.action
            when :templates
              allow! if permission_action.action == :index
            when :questionnaire
              allow!
            end
          end

          permission_action
        end

        private

        def participatory_space
          @participatory_space ||= context[:proposal].try(:participatory_space)
        end

        def user_roles
          @user_roles ||= participatory_space.try(:user_roles)
        end

        def user_has_a_role?
          return unless user_roles

          user_roles.exists?(user:)
        end
      end
    end
  end
end
