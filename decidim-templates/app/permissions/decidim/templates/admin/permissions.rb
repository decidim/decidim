# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action if context[:current_organization] != user.organization

          if read_template_action? || allows_questionnaire_template_action?
            allow!
          elsif user.admin?
            case permission_action.subject
            when :template
              allow! if [:read, :create, :update, :destroy, :copy].include? permission_action.action
            when :templates
              allow! if permission_action.action == :index
            when :questionnaire
              allow!
            when :questionnaire_template
              allow! if [:preview, :apply, :skip].include? permission_action.action
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

        def read_template_action?
          user_has_a_role? && permission_action.subject == :template && permission_action.action == :read
        end

        # Allows a user who is able to edit the target questionnaire to preview,
        # apply or skip questionnaire templates. Organization admins can always
        # perform these actions. "preview" has no target questionnaire to scope
        # to, so it is allowed to any user holding a role in a participatory
        # space, as it is only reachable from an already authorized form.
        def allows_questionnaire_template_action?
          return false unless permission_action.subject == :questionnaire_template
          return false unless [:preview, :apply, :skip].include?(permission_action.action)
          return true if user.admin?

          if (component = context[:component]).present?
            return user_can_manage_component?(component)
          end

          permission_action.action == :preview && user_has_any_role?(user, nil, broad_check: true)
        end

        # Checks the user can manage the given component by delegating the
        # `:manage, :component` action to the component's own permission chain,
        # so that space admins are authorized while other roles are not.
        def user_can_manage_component?(component)
          [
            component.manifest.permissions_class,
            component.participatory_space.manifest.permissions_class,
            Decidim::Admin::Permissions
          ].inject(permission_action_for_manage_component) do |action, permission_class|
            permission_class.new(
              user,
              action,
              context.merge(component:, current_participatory_space: component.participatory_space)
            ).permissions
          end.allowed?
        rescue Decidim::PermissionAction::PermissionNotSetError
          false
        end

        def permission_action_for_manage_component
          Decidim::PermissionAction.new(scope: :admin, action: :manage, subject: :component)
        end
      end
    end
  end
end
