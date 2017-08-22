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
          end
        end
      end
    end
  end
end
