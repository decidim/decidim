# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class Permissions < Decidim::DefaultPermissions
      def permissions
        user_can_enter_processes_space_area?
        user_can_enter_process_groups_space_area?

        return permission_action if process && !process.is_a?(Decidim::ParticipatoryProcess)

        if read_admin_dashboard_action?
          user_can_read_admin_dashboard?
          return permission_action
        end

        if permission_action.scope == :public
          public_list_processes_action?
          public_list_process_groups_action?
          public_read_process_group_action?
          public_read_process_action?
          public_report_content_action?
          return permission_action
        end

        return permission_action unless user
        if !has_manageable_processes? && !user.admin?
          disallow!
          return permission_action
        end
        return permission_action unless permission_action.scope == :admin

        valid_process_group_action?

        user_can_read_process_list?
        user_can_read_current_process?
        user_can_create_process?
        user_can_destroy_process?

        # org admins and space admins can do everything in the admin section
        org_admin_action?

        return permission_action unless process

        moderator_action?
        collaborator_action?
        process_admin_action?

        permission_action
      end

      private

      # It's an admin user if it's an organization admin or is a space admin
      # for the current `process`.
      def admin_user?
        user.admin? || (process ? can_manage_process?(role: :admin) : has_manageable_processes?)
      end

      # Checks if it has any manageable process, with any possible role.
      def has_manageable_processes?(role: :any)
        return unless user
        participatory_processes_with_role_privileges(role).any?
      end

      # Whether the user can manage the given process or not.
      def can_manage_process?(role: :any)
        return unless user
        participatory_processes_with_role_privileges(role).include? process
      end

      # Returns a collection of Participatory processes where the given user has the
      # specific role privilege.
      def participatory_processes_with_role_privileges(role)
        Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
      end

      def public_list_processes_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :process

        allow!
      end

      def public_list_process_groups_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :process_group

        allow!
      end

      def public_read_process_group_action?
        return unless permission_action.action == :read &&
                      permission_action.subject == :process_group &&
                      process_group

        allow!
      end

      def public_read_process_action?
        return unless permission_action.action == :read &&
                      [:process, :participatory_space].include?(permission_action.subject) &&
                      process

        return allow! if user&.admin?
        return allow! if process.published?
        toggle_allow(can_manage_process?)
      end

      def public_report_content_action?
        return unless permission_action.action == :create &&
                      permission_action.subject == :moderation

        allow!
      end

      # Only organization admins can enter the process groups space area.
      def user_can_enter_process_groups_space_area?
        return unless permission_action.action == :enter &&
                      permission_action.scope == :admin &&
                      permission_action.subject == :space_area &&
                      context.fetch(:space_name, nil) == :process_groups

        toggle_allow(user.admin?)
      end

      # All users with a relation to a process and organization admins can enter
      # the processes space area.
      def user_can_enter_processes_space_area?
        return unless permission_action.action == :enter &&
                      permission_action.scope == :admin &&
                      permission_action.subject == :space_area &&
                      context.fetch(:space_name, nil) == :processes

        toggle_allow(user.admin? || has_manageable_processes?)
      end

      # Only organization admins can manage process groups.
      def valid_process_group_action?
        return unless permission_action.subject == :process_group
        toggle_allow(user.admin?)
      end

      # Checks if the permission_action is to read in the admin or not.
      def admin_read_permission_action?
        permission_action.action == :read
      end

      def read_admin_dashboard_action?
        permission_action.action == :read &&
          permission_action.subject == :admin_dashboard
      end

      # Any user that can enter the space area can read the admin dashboard.
      def user_can_read_admin_dashboard?
        allow! if user.admin? || has_manageable_processes?
      end

      # Only organization admins can create a process
      def user_can_create_process?
        return unless permission_action.action == :create &&
                      permission_action.subject == :process

        toggle_allow(user.admin?)
      end

      # Only organization admins can destroy a process
      def user_can_destroy_process?
        return unless permission_action.action == :destroy &&
                      permission_action.subject == :process

        toggle_allow(user.admin?)
      end

      # Everyone can read the process list
      def user_can_read_process_list?
        return unless read_process_list_permission_action?
        toggle_allow(user.admin? || has_manageable_processes?)
      end

      def user_can_read_current_process?
        return unless read_process_list_permission_action?
        return if permission_action.subject == :process_list
        toggle_allow(user.admin? || can_manage_process?)
      end

      # A moderator needs to be able to read the process they are assigned to,
      # and needs to perform all actions for the moderations of that process.
      def moderator_action?
        return unless can_manage_process?(role: :moderator)

        allow! if permission_action.subject == :moderation
      end

      # Collaborators can read/preview everything inside their process.
      def collaborator_action?
        return unless can_manage_process?(role: :collaborator)

        allow! if permission_action.action == :read || permission_action.action == :preview
      end

      # Process admins can eprform everything *inside* that process. They cannot
      # create a process or perform actions on process groups or other
      # processes. They cannot destroy their process either.
      def process_admin_action?
        return unless can_manage_process?(role: :admin)
        return if user.admin?
        return disallow! if permission_action.action == :create &&
                            permission_action.subject == :process
        return disallow! if permission_action.action == :destroy &&
                            permission_action.subject == :process

        is_allowed = [
          :attachment,
          :attachment_collection,
          :category,
          :component,
          :component_data,
          :moderation,
          :process,
          :process_step,
          :process_user_role
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      def org_admin_action?
        return unless user.admin?

        is_allowed = [
          :attachment,
          :attachment_collection,
          :category,
          :component,
          :component_data,
          :moderation,
          :process,
          :process_step,
          :process_user_role,
          :space_private_user
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      # Checks if the permission_action is to read the admin processes list or
      # not.
      def read_process_list_permission_action?
        permission_action.action == :read &&
          [:process, :participatory_space, :process_list].include?(permission_action.subject)
      end

      def process
        @process ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil)
      end

      def process_group
        @process_group ||= context.fetch(:process_group, nil)
      end
    end
  end
end
