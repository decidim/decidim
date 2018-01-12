# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      module Admin
        # Defines the abilities for an assembly admin user, whatever they role. Intended to be used
        # with `cancancan`.
        class AssemblyRoleAbility
          include CanCan::Ability

          def initialize(user, context)
            @user = user
            @context = context

            # Define abilities if the user is not an admin and has at least one assembly to manage.
            if not_admin? && has_manageable_assemblies?
              define_abilities

              if current_assembly && can_manage_assembly?(current_assembly)
                define_assembly_abilities
              end
            end
          end

          # Grant access to admin panel by default.
          def define_abilities
            can :read, :admin_dashboard
          end

          def define_assembly_abilities; end

          # Abstract: A subclass must define this method returning a valid role.
          # See ParticipatoryProcessUserRoles::ROLES for more information.
          def role
            raise "Needs implementation"
          end

          # Whether the user is an admin or not.
          def not_admin?
            @user && !@user.admin?
          end

          # Returns a collection of assemblies where the given user has the
          # specific role privilege.
          def assemblies_with_role_privileges
            @assemblies ||= Decidim::Assemblies::AssembliesWithUserRole.for(@user, role)
          end

          # Whether the user has at least one assembly to manage or not.
          def has_manageable_assemblies?
            assemblies_with_role_privileges.any?
          end

          # Whether the user can manage the given assembly or not.
          def can_manage_assembly?(assembly)
            assemblies_with_role_privileges.include? assembly
          end

          def current_assembly
            @current_assembly ||= @context[:current_assembly]
          end
        end
      end
    end
  end
end
