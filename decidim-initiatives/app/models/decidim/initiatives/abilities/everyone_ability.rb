# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      # Defines the base abilities related to initiatives for any user. Guest
      # users will use these too. Intended to be used with `cancancan`.
      class EveryoneAbility < Decidim::Abilities::EveryoneAbility
        def initialize(user, context)
          super(user, context)

          can :read, Initiative do |initiative|
            initiative.published? || initiative.rejected? || initiative.accepted?
          end

          can :search, InitiativesType
          can :search, InitiativesTypeScope
        end
      end
    end
  end
end
