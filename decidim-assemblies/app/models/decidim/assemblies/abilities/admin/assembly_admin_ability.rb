# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      module Admin
        # Defines the abilities for an assembly admin user. Intended to be used
        # with `cancancan`.
        class AssemblyAdminAbility < Decidim::Assemblies::Abilities::Admin::AssemblyRoleAbility
          def define_abilities
            super

            can :manage, Assembly do |assembly|
              can_manage_assembly?(assembly)
            end

            cannot :create, Assembly
            cannot :destroy, Assembly
          end

          def role
            :admin
          end

          def define_assembly_abilities
            can :manage, Component do |component|
              can_manage_assembly?(component.participatory_space)
            end

            can :manage, Category do |category|
              can_manage_assembly?(category.participatory_space)
            end

            can :manage, Attachment do |attachment|
              attachment.attached_to.is_a?(Decidim::Assembly) && can_manage_assembly?(attachment.attached_to)
            end

            can :manage, AttachmentCollection do |attachment_collection|
              attachment_collection.collection_for.is_a?(Decidim::Assembly) && can_manage_assembly?(attachment_collection.collection_for)
            end

            can :manage, AssemblyMember do |member|
              can_manage_assembly?(member.assembly)
            end

            can :manage, AssemblyUserRole do |role|
              can_manage_assembly?(role.assembly) && role.user != @user
            end

            can :manage, Moderation do |moderation|
              can_manage_assembly?(moderation.participatory_space)
            end

            can [:unreport, :hide], Reportable do |reportable|
              can_manage_assembly?(reportable.component.participatory_space)
            end
          end
        end
      end
    end
  end
end
