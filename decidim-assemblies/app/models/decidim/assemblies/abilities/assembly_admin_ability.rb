# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      # Defines the abilities for an assembly admin user.
      # Intended to be used with `cancancan`.
      class AssemblyAdminAbility < Decidim::Assemblies::Abilities::AssemblyRoleAbility
        def role
          :admin
        end
      end
    end
  end
end
