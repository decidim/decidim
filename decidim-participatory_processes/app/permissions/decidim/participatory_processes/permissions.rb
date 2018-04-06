# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class Permissions
      def initialize(user, permission_action, context = {})
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def allowed?
        return true if permission_action.scope == :public

        return false unless user
        return false unless permission_action.scope == :admin

        return true if enter_space_area_action?

        # this line could probably be moved to the `admin` engine
        # and make it call all participatory spaces Permissions classes
        # to check if any of them allowed the user to visit the admin
        return true if has_manageable_processes? && admin_read_dashboard_permission_action?

        return true if has_manageable_processes? && admin_read_process_permission_action?
        return true if has_manageable_processes? && admin_read_process_group_permission_action?

        # org admins and space admins can do everything in the admin section
        return true if admin_user?

        # space collaborators can only read, nothing else
        return true if collaborator_user? && admin_read_permission_action?

        return true if permission_action.subject == :moderation && can_manage_process?

        false
      end

      private

      attr_reader :user, :context, :permission_action

      # It's an admin user if it's an organization admin or is a space admin
      # for the current `process`.
      def admin_user?
        user.admin? || (process ? can_manage_process?(role: :admin) : has_manageable_processes?)
      end

      # It's an admin user if it's an space collaborator for the current `process`.
      def collaborator_user?
        can_manage_process?(role: :collaborator)
      end

      # Checks if it has any manageable process, with any possible role.
      def has_manageable_processes?(role: :any)
        participatory_processes_with_role_privileges(role).any?
      end

      # Whether the user can manage the given process or not.
      def can_manage_process?(role: :any)
        participatory_processes_with_role_privileges(role).include? process
      end

      # Returns a collection of Participatory processes where the given user has the
      # specific role privilege.
      def participatory_processes_with_role_privileges(role)
        Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
      end

      def enter_space_area_action?
        return unless permission_action.action == :enter &&
          permission_action.subject == :space_area

        user.admin? || has_manageable_processes?
      end

      # Checks if the permission_action is to read in the admin or not.
      def admin_read_permission_action?
        permission_action.action == :read
      end

      # Checks if the permission_action is to read the admin dashboard or not.
      def admin_read_dashboard_permission_action?
        permission_action.action == :read &&
          permission_action.subject == :dashboard
      end

      # Checks if the permission_action is to read the admin processes or not.
      def admin_read_process_permission_action?
        return unless permission_action.action == :read &&
          [:process, :participatory_space].include?(permission_action.subject)

        admin_user?
      end

      def admin_read_process_group_permission_action?
        return unless permission_action.action == :read &&
          permission_action.subject == :process_group

        admin_user?
      end

      def process
        @process ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil)
      end
    end
  end
end
