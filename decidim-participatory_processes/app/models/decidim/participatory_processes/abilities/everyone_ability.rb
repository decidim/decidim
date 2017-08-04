# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Abilities
      # Defines the base abilities related to participatory processes for any
      # user. Guest users will use these too. Intended to be used with
      # `cancancan`.
      class EveryoneAbility < Decidim::Abilities::EveryoneAbility
        def initialize(user, context)
          super(user, context)

          can :read, ParticipatoryProcessGroup
          can :read, ParticipatoryProcess, &:published?
        end
      end
    end
  end
end
