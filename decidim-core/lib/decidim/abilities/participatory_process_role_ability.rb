# frozen_string_literal: true

module Decidim
  module Abilities
    # Base class used for any participatory process role ability.
    class ParticipatoryProcessRoleAbility
      include CanCan::Ability

      def initialize(user, context)
        @user = user
        @context = context

        # Define abilities if the user is not an admin and has at least one process to manage.
        if not_admin? && has_manageable_processes?
          define_abilities

          if current_participatory_process && can_manage_process?(current_participatory_process)
            define_participatory_process_abilities
          end
        end
      end

      # Grant access to admin panel by default.
      def define_abilities
        can :read, :admin_dashboard
      end

      def define_participatory_process_abilities; end

      # Abstract: A subclass must define this method returning a valid role.
      # See ParticipatoryProcessUserRoles::ROLES for more information.
      def role
        raise "Needs implementation"
      end

      # Whether the user is an admin or not.
      def not_admin?
        !@user&.admin?
      end

      # Returns a collection of Participatory processes where the given user has the
      # specific role privilege.
      def participatory_processes_with_role_privileges
        @participatory_processes ||= Decidim::ParticipatoryProcessesWithUserRole.for(@user, role)
      end

      # Whether the user has at least one process to manage or not.
      def has_manageable_processes?
        participatory_processes_with_role_privileges.any?
      end

      # Whether the user can manage the given process or not.
      def can_manage_process?(process)
        participatory_processes_with_role_privileges.include? process
      end

      def current_participatory_process
        @current_participatory_process ||= @context[:current_participatory_process]
      end
    end
  end
end
