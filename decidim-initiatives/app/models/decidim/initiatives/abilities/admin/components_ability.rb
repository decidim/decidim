# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to user able to administer components for an initiative.
        # Intended to be used with `cancancan`.
        class ComponentsAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return if user&.admin?

            @user = user
            @context = context
          end
        end
      end
    end
  end
end
