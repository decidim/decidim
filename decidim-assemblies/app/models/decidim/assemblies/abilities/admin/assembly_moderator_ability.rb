# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      module Admin
        # Defines the abilities for an assembly moderator user. Intended to be used
        # with `cancancan`.
        class AssemblyModeratorAbility < Decidim::Assemblies::Abilities::Admin::AssemblyRoleAbility
          def define_abilities
            super

            can [:index, :read], Assembly do |assembly|
              can_manage_assembly?(assembly)
            end

            can :manage, Moderation do |moderation|
              can_manage_assembly?(moderation.participatory_space)
            end

            can [:unreport, :hide], Reportable do |reportable|
              can_manage_assembly?(reportable.component.participatory_space)
            end
          end

          def role
            :moderator
          end
        end
      end
    end
  end
end
