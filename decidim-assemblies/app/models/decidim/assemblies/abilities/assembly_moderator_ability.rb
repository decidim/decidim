# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      # Defines the abilities for an assembly moderator user
      # Intended to be used with `cancancan`.
      class AssemblyModeratorAbility < Decidim::Assemblies::Abilities::AssemblyRoleAbility
        def role
          :moderator
        end
      end
    end
  end
end
