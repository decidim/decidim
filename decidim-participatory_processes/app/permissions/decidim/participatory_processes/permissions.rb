# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class Permissions < Decidim::DefaultPermissions
      include Decidim::UserRoleChecker

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
          public_list_members_action?
          public_read_process_group_action?
          public_read_process_action?
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
        user_can_upload_images_in_process?

        # org admins and space admins can do everything in the admin section
        org_admin_action?

        return permission_action unless process

        user_can_read_private_users?

        moderator_action?
        collaborator_action?
        evaluator_action?
        process_admin_action?
        permission_action
      end

      private

      def user_can_read_private_users?
        return unless permission_action.subject == :space_private_user
        return unless process.private_space?

        toggle_allow(user.admin? || can_manage_process?(role: :admin) || can_manage_process?(role: :collaborator))
      end

      # It is an admin user if it is an organization admin or is a space admin
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

      def public_list_members_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :members

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

        return disallow! unless can_view_private_space?
        return allow! if user&.admin?
        return allow! if process.published?
        return allow! if user_can_preview_space?

        toggle_allow(can_manage_process?)
      end

      def can_view_private_space?
        return true unless process.private_space
        return false unless user

        user.admin || process.users.include?(user)
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

      # Collaborators can only preview their own processes.
      def collaborator_action?
        return unless can_manage_process?(role: :collaborator)
        return if permission_action.subject == :space_private_user

        allow! if permission_action.action == :preview
      end

      # Evaluators can only read the components of a process.
      def evaluator_action?
        return unless can_manage_process?(role: :evaluator)

        allow! if permission_action.action == :read && permission_action.subject == :component
        allow! if permission_action.action == :export && permission_action.subject == :component_data
      end

      # Process admins can perform everything *inside* that process. They cannot
      # create a process or perform actions on process groups or other
      # processes.
      def process_admin_action?
        return unless can_manage_process?(role: :admin)
        return if user.admin?
        return disallow! if permission_action.action == :create &&
                            permission_action.subject == :process

        is_allowed = [
          :attachment,
          :attachment_collection,
          :component,
          :component_data,
          :moderation,
          :process,
          :process_step,
          :process_user_role,
          :export_space,
          :share_tokens,
          :import
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      def org_admin_action?
        return unless user.admin?

        is_allowed = [
          :attachment,
          :attachment_collection,
          :component,
          :component_data,
          :moderation,
          :process,
          :process_step,
          :process_user_role,
          :export_space,
          :share_tokens,
          :import
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      def user_can_preview_space?
        context[:share_token].present? && Decidim::ShareToken.use!(token_for: process, token: context[:share_token], user:)
      rescue ActiveRecord::RecordNotFound, StandardError
        nil
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

      def user_can_upload_images_in_process?
        allow! if user&.admin_terms_accepted? && user_has_any_role?(user, process, broad_check: true) && (permission_action.subject == :editor_image)
      end
    end
  end
end
