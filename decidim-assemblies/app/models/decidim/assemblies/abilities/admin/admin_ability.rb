# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      module Admin
        # Defines the abilities for an admin user. Intended to be used with `cancancan`.
        class AdminAbility < Decidim::Abilities::AdminAbility
          def define_abilities
            super

            can :manage, Assembly
            can :manage, Decidim::AssemblyMember
            can :manage, Decidim::AssemblyUserRole
            can :manage, Decidim::ParticipatorySpacePrivateUser
          end
        end
      end
    end
  end
end
