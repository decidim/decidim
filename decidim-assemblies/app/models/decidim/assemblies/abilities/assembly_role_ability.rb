# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      # Defines the abilities for any user that can manage assemblies (whatever their role).
      # Intended to be used with `cancancan`.
      class AssemblyRoleAbility
        include CanCan::Ability

        attr_reader :user

        def initialize(user, context)
          @user = user
          @context = context

          define_abilities if not_admin? && has_manageable_assemblies?
        end

        def define_abilities
          can :read, :admin_dashboard
          can :read, Assembly
          can :read, AssemblyMember
        end

        private

        # Whether the user is an admin or not.
        def not_admin?
          @user && !@user.admin?
        end

        # Abstract: A subclass must define this method returning a valid role.
        # See AssemblyUserRole::ROLES for more information.
        def role
          raise "Needs implementation"
        end

        # Returns a collection of Participatory assemblies where the given user has the
        # specific role privilege.
        def assemblies_with_role_privileges
          @assemblies_with_role_privileges ||= Decidim::Assemblies::AssembliesWithUserRole.for(@user, role)
        end

        # Whether the user has at least one assembly to manage or not.
        def has_manageable_assemblies?
          assemblies_with_role_privileges.any?
        end
      end
    end
  end
end
