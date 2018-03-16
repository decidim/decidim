# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for a participatory process collaborator. Intended to be
    # used with `cancancan`.
    # This ability will not apply to organization admins.
    class ParticipatoryProcessCollaboratorAbility < ParticipatoryProcessRoleAbility
      # Overrides ParticipatoryProcessRoleAbility role method
      def role
        :collaborator
      end

      # Overrides ParticipatoryProcessRoleAbility define_participatory_process_abilities method
      def define_participatory_process_abilities
        super

        can :read, ParticipatoryProcess do |process|
          can_manage_process?(process)
        end

        can :read, Component do |component|
          can_manage_process?(component.participatory_space)
        end
      end
    end
  end
end
