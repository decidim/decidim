# frozen_string_literal: true

module Decidim
  module Abilities
    # TODO
    class ParticipatoryProcessRoleUser
      include CanCan::Ability

      def initialize(user, context)
        @user = user
        @context = context

        define_abilities if not_admin? && has_manageable_processes?
        define_participatory_process_abilities if current_participatory_process && can_manage_process?(current_participatory_process)
      end

      def define_abilities
        can :read, :admin_dashboard
      end

      def define_participatory_process_abilities; end

      def role
        raise "Needs implementation"
      end

      def not_admin?
        @user && !@user.admin?
      end

      def participatory_processes_with_role_privileges
        @participatory_processes ||= Decidim::ParticipatoryProcessesWithUserRole.for(@user, role)
      end

      def has_manageable_processes?
        participatory_processes_with_role_privileges.any?
      end

      def can_manage_process?(process)
        participatory_processes_with_role_privileges.include? process
      end

      def current_participatory_process
        @current_participatory_process ||= @context[:current_participatory_process]
      end
    end
  end
end
