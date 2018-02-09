# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      module Admin
        # Defines the abilities for an assembly collaborator user. Intended to be used
        # with `cancancan`.
        class AssemblyCollaboratorAbility < Decidim::Assemblies::Abilities::Admin::AssemblyRoleAbility
          def define_abilities
            super

            can [:read, :preview], Assembly do |assembly|
              can_manage_assembly?(assembly)
            end
          end

          def role
            :collaborator
          end
        end
      end
    end
  end
end
