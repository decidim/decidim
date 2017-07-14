# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for a participatory process collaborator. Intended to be
    # used with `cancancan`.
    # This ability will not apply to organization admins.
    class ParticipatoryProcessCollaborator
      include CanCan::Ability

      def initialize(user, context)
        @user = user
        @context = context

        define_abilities if @user && !@user.admin? && has_manageable_processes?
      end

      def define_abilities
        can :read, :admin_dashboard
      end

      def participatory_processes_with_admin_role
        @participatory_processes ||= Decidim::ParticipatoryProcessesWithUserRole.for(@user, :collaborator)
      end

      def has_manageable_processes?
        participatory_processes_with_admin_role.any?
      end
    end
  end
end