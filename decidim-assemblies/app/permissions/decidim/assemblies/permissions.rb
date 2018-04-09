# frozen_string_literal: true

module Decidim
  module Assemblies
    class Permissions
      def initialize(user, permission_action, context = {})
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def permissions
        permission_action.allow! if permission_action.scope == :public

        return permission_action unless user
        return permission_action unless permission_action.scope == :admin

        permission_action.allow! if has_manageable_assemblies? && admin_read_dashboard_permission_action?

        # org admins and space admins can do everything in the admin section
        permission_action.allow! if admin_user?

        # space collaborators can only read, nothing else
        permission_action.allow! if collaborator_user? && admin_read_permission_action?

        permission_action.allow! if permission_action.subject == :moderation && can_manage_assembly?

        permission_action
      end

      private

      attr_reader :user, :context, :permission_action

      # It's an admin user if it's an organization admin or is a space admin
      # for the current `assembly`.
      def admin_user?
        user.admin? || can_manage_assembly?(role: :admin)
      end

      # It's an admin user if it's an space collaborator for the current `assembly`.
      def collaborator_user?
        can_manage_assembly?(role: :collaborator)
      end

      # Checks if it has any manageable assembly, with any possible role.
      def has_manageable_assemblies?(role: :any)
        assemblies_with_role_privileges(role).any?
      end

      # Whether the user can manage the given assembly or not.
      def can_manage_assembly?(role: :any)
        assemblies_with_role_privileges(role).include? assembly
      end

      # Returns a collection of Participatory assemblies where the given user has the
      # specific role privilege.
      def assemblies_with_role_privileges(role)
        Decidim::Assemblies::AssembliesWithUserRole.for(user, role)
      end

      # Checks if the permission_action is to read in the admin or not.
      def admin_read_permission_action?
        permission_action.action == :read
      end

      # Checks if the permission_action is to read the admin dashboard or not.
      def admin_read_dashboard_permission_action?
        permission_action.scope == :admin &&
          permission_action.action == :read &&
          permission_action.subject == :dashboard
      end

      def assembly
        @assembly ||= context.fetch(:current_participatory_space, nil)
      end
    end
  end
end
