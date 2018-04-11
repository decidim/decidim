# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class Permissions < Decidim::DefaultPermissions
      def permissions
        if permission_action.scope == :public
          public_list_processes_action?
          public_list_process_groups_action?
          public_read_process_group_action?
          public_read_process_action?
          public_report_content_action?
          return permission_action
        end

        return permission_action unless user
        return permission_action if !has_manageable_processes? && !user.admin?
        return permission_action unless permission_action.scope == :admin

        permission_action.allow! if user_can_enter_space_area?

        permission_action.allow! if valid_process_group_action?

        permission_action.allow! if user_can_read_admin_dashboard?

        permission_action.allow! if user_can_read_process?
        permission_action.allow! if user_can_create_process?
        permission_action.allow! if user_can_destroy_process?

        # org admins and space admins can do everything in the admin section
        permission_action.allow! if org_admin_action?

        return permission_action unless process

        permission_action.allow! if moderator_action?
        permission_action.allow! if collaborator_action?
        permission_action.allow! if process_admin_action?

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

      # All users with a relation to a process and organization admins can enter
      # the space area. The sapce area is considered to be the processes zone,
      # not the process groups one.
      def user_can_enter_space_area?
        return unless permission_action.action == :enter &&
                      permission_action.subject == :space_area

        user.admin? || has_manageable_processes?
      end

      # Only organization admins can manage process groups.
      def valid_process_group_action?
        permission_action.subject == :process_group && user.admin?
      end

      # Checks if the permission_action is to read in the admin or not.
      def admin_read_permission_action?
        permission_action.action == :read
      end

      # Any user that can enter the space area can read the admin dashboard.
      def user_can_read_admin_dashboard?
        return unless permission_action.action == :read &&
                      permission_action.subject == :admin_dashboard

        user.admin? || has_manageable_processes?
      end

      # Only organization admins can create a process
      def user_can_create_process?
        return unless permission_action.action == :create &&
                      permission_action.subject == :process

        user.admin?
      end

      # Only organization admins can destroy a process
      def user_can_destroy_process?
        return unless permission_action.action == :create &&
                      permission_action.subject == :destroy

        user.admin?
      end

      # Everyone can read the process list
      def user_can_read_process?
        read_process_list_permission_action? && (user.admin? || has_manageable_processes?)
      end

      # A moderator needs to be able to read the process they are assigned to,
      # and needs to perform all actions for the moderations of that process.
      def moderator_action?
        return unless can_manage_process?(role: :moderator)

        permission_action.subject == :moderation
      end

      # Collaborators can read/preview everything inside their process.
      def collaborator_action?
        return unless can_manage_process?(role: :collaborator)

        permission_action.action == :read ||
          permission_action.action == :preview
      end

      # Process admins can eprform everything *inside* that process. They cannot
      # create a process or perform actions on process groups or other
      # processes. They cannot destroy their process either.
      def process_admin_action?
        return unless can_manage_process?(role: :admin)
        return if permission_action.action == :create &&
                  permission_action.subject == :process
        return if permission_action.action == :destroy &&
                  permission_action.subject == :process

        [
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
      end

      def org_admin_action?
        return unless user.admin?

        [
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
