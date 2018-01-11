# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      # Defines the abilities for an assembly admin user. Intended to be used with `cancancan`.
      class AssemblyAdminAbility < Decidim::Abilities::AdminAbility
        include CanCan::Ability

        attr_reader :user

        def initialize(user, context)
          @user = user
          @context = context

          define_abilities if not_admin? && has_manageable_assemblies?
        end

        def define_abilities
          super

          can :read, Assembly
        end

        private

        # Whether the user is an admin or not.
        def not_admin?
          @user && !@user.admin?
        end

        # Returns a collection of Participatory assemblies where the given user has the
        # specific role privilege.
        def assemblies_with_role_privileges
          @assemblies ||= Decidim::Assemblies::AssembliesWithUserRole.for(@user, :admin)
        end

        # Whether the user has at least one assembly to manage or not.
        def has_manageable_assemblies?
          assemblies_with_role_privileges.any?
        end
      end
    end
  end
end
