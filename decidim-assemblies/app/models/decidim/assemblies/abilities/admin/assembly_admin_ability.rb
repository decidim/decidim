# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      module Admin
        # Defines the abilities for an assembly admin user. Intended to be used
        # with `cancancan`.
        class AssemblyAdminAbility
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

            can :manage, Assembly do |assembly|
              can_manage_assembly?(assembly)
            end

            cannot :create, Assembly
            cannot :destroy, Assembly
          end

          def define_assembly_abilities
            can :manage, Feature do |feature|
              can_manage_assembly?(feature.participatory_space)
            end

            can :manage, Category do |category|
              can_manage_assembly?(category.participatory_space)
            end

            can :manage, Attachment do |attachment|
              attachment.attached_to.is_a?(Decidim::Assembly) && can_manage_assembly?(attachment.attached_to)
            end

            can :manage, AssemblyUserRole do |role|
              can_manage_assembly?(role.assembly) && role.user != @user
            end

            can :manage, Moderation do |moderation|
              can_manage_assembly?(moderation.participatory_space)
            end
          end

          def role
            :admin
          end

          # Whether the user is an admin or not.
          def not_admin?
            @user && !@user.admin?
          end

          # Returns a collection of Participatory assemblies where the given user has the
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
