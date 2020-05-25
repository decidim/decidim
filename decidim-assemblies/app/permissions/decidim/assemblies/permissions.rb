# frozen_string_literal: true

module Decidim
  module Assemblies
    class Permissions < Decidim::DefaultPermissions
      def permissions
        user_can_enter_space_area?

        return permission_action if assembly && !assembly.is_a?(Decidim::Assembly)

        if read_admin_dashboard_action?
          user_can_read_admin_dashboard?
          return permission_action
        end

        if permission_action.scope == :public
          public_list_assemblies_action?
          public_read_assembly_action?
          public_list_members_action?
          public_report_content_action?
          return permission_action
        end

        return permission_action unless user

        if !has_manageable_assemblies? && !user.admin?
          disallow!
          return permission_action
        end
        return permission_action unless permission_action.scope == :admin

        user_can_read_assembly_list?
        user_can_list_assembly_list?
        user_can_read_current_assembly?
        user_can_create_assembly?
        user_can_read_assemblies_setting?

        # org admins and space admins can do everything in the admin section
        org_admin_action?
        assemblies_type_action?

        return permission_action unless assembly

        moderator_action?
        collaborator_action?
        valuator_action?
        assembly_admin_action?

        permission_action
      end

      private

      def assemblies_type_action?
        return unless [:assembly_type, :assemblies_type].include? permission_action.subject
        return disallow! unless user.admin?

        assembly_type = context.fetch(:assembly_type, nil)
        case permission_action.action
        when :destroy
          assemblies_is_empty = assembly_type && assembly_type.assemblies.empty?

          toggle_allow(assemblies_is_empty)
        else
          allow!
        end
      end

      # It's an admin user if it's an organization admin or is a space admin
      # for the current `assembly`.
      def admin_user?
        user.admin? || (assembly ? can_manage_assembly?(role: :admin) : has_manageable_assemblies?)
      end

      # Checks if it has any manageable assembly, with any possible role.
      def has_manageable_assemblies?(role: :any)
        return unless user

        assemblies_with_role_privileges(role).any?
      end

      # Whether the user can manage the given assembly or not.
      def can_manage_assembly?(role: :any)
        return unless user

        assemblies_with_role_privileges(role).include? assembly
      end

      # Returns a collection of assemblies where the given user has the
      # specific role privilege.
      def assemblies_with_role_privileges(role)
        Decidim::Assemblies::AssembliesWithUserRole.for(user, role)
      end

      def public_list_assemblies_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :assembly

        allow!
      end

      def public_read_assembly_action?
        return unless permission_action.action == :read &&
                      [:assembly, :participatory_space].include?(permission_action.subject) &&
                      assembly

        return disallow! unless can_view_private_space?
        return allow! if user&.admin?
        return allow! if assembly.published?

        toggle_allow(can_manage_assembly?)
      end

      def can_view_private_space?
        return true unless assembly.private_space && !assembly.is_transparent?
        return false unless user

        user.admin || assembly.users.include?(user)
      end

      def public_list_members_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :members

        allow!
      end

      def public_report_content_action?
        return unless permission_action.action == :create &&
                      permission_action.subject == :moderation

        allow!
      end

      # All users with a relation to a assembly and organization admins can enter
      # the space area. The sapce area is considered to be the assemblies zone,
      # not the assembly groups one.
      def user_can_enter_space_area?
        return unless permission_action.action == :enter &&
                      permission_action.scope == :admin &&
                      permission_action.subject == :space_area &&
                      context.fetch(:space_name, nil) == :assemblies

        toggle_allow(user.admin? || has_manageable_assemblies?)
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
        allow! if user.admin? || has_manageable_assemblies?
      end

      # Only organization admins can create a assembly
      def user_can_create_assembly?
        return unless permission_action.action == :create &&
                      permission_action.subject == :assembly

        toggle_allow(user.admin?)
      end

      def user_can_read_assemblies_setting?
        return unless permission_action.action == :read &&
                      permission_action.subject == :assemblies_setting

        toggle_allow(user.admin?)
      end

      # Everyone can read the assembly list
      def user_can_read_assembly_list?
        return unless read_assembly_list_permission_action?

        toggle_allow(user.admin? || has_manageable_assemblies?)
      end

      # Checks whether the user can list the current given assembly or not.
      #
      # In case of user being admin of child assembly even parent assembly
      # should be listed to be able to navigate to child assembly
      def user_can_list_assembly_list?
        return unless permission_action.action == :list &&
                      permission_action.subject == :assembly

        toggle_allow(user.admin? || allowed_list_of_assemblies?)
      end

      def allowed_list_of_assemblies?
        assemblies = AssembliesWithUserRole.for(user)
        parent_assemblies = assemblies.flat_map { |assembly| [assembly.id] + assembly.ancestors.pluck(:id) }

        allowed_list_of_assemblies = Decidim::Assembly.where(id: assemblies + parent_assemblies)
        allowed_list_of_assemblies.uniq.member?(assembly)
      end

      def user_can_read_current_assembly?
        return unless read_assembly_list_permission_action?
        return if permission_action.subject == :assembly_list

        toggle_allow(user.admin? || can_manage_assembly?)
      end

      # A moderator needs to be able to read the assembly they are assigned to,
      # and needs to perform all actions for the moderations of that assembly.
      def moderator_action?
        return unless can_manage_assembly?(role: :moderator)

        allow! if permission_action.subject == :moderation
      end

      # Collaborators can read/preview everything inside their assembly.
      def collaborator_action?
        return unless can_manage_assembly?(role: :collaborator)

        allow! if permission_action.action == :read || permission_action.action == :preview
      end

      # Valuators can only read the assembly components
      def valuator_action?
        return unless can_manage_assembly?(role: :valuator)

        allow! if permission_action.action == :read && permission_action.subject == :component
        allow! if permission_action.action == :export && permission_action.subject == :component_data
      end

      # Process admins can perform everything *inside* that assembly. They cannot
      # create a assembly or perform actions on assembly groups or other
      # assemblies.
      def assembly_admin_action?
        return unless can_manage_assembly?(role: :admin)
        return if user.admin?
        return disallow! if permission_action.action == :create &&
                            permission_action.subject == :assembly

        is_allowed = [
          :attachment,
          :attachment_collection,
          :category,
          :component,
          :component_data,
          :moderation,
          :assembly,
          :assembly_user_role,
          :assembly_member,
          :space_private_user
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
          :assembly,
          :assembly_user_role,
          :assembly_member,
          :space_private_user,
          :assemblies_setting
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      # Checks if the permission_action is to read the admin assemblies list or
      # not.
      def read_assembly_list_permission_action?
        permission_action.action == :read &&
          [:assembly, :participatory_space, :assembly_list].include?(permission_action.subject)
      end

      def assembly
        @assembly ||= context.fetch(:current_participatory_space, nil) || context.fetch(:assembly, nil)
      end
    end
  end
end
