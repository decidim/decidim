# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      # Defines the abilities for an assembly collaborator user
      # Intended to be used with `cancancan`.
      class AssemblyCollaboratorAbility < Decidim::Assemblies::Abilities::AssemblyRoleAbility
        def role
          :collaborator
        end
      end
    end
  end
end
