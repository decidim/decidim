# frozen_string_literal: true

module Decidim
  module Assemblies
    module Abilities
      # Defines the abilities for an admin user. Intended to be used with `cancancan`.
      class AdminAbility < Decidim::Abilities::AdminAbility
        def define_abilities
          super

          can :read, Assembly
        end
      end
    end
  end
end
