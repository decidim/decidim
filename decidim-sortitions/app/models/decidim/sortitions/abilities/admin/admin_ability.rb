# frozen_string_literal: true

module Decidim
  module Sortitions
    module Abilities
      module Admin
        # Defines the abilities for a user in the admin section. Intended to be
        # used with `cancancan`.
        class AdminAbility < Decidim::Abilities::AdminAbility
          def define_abilities
            super

            can :manage, Sortition
            cannot :destroy, Sortition
            can :destroy, Sortition do |sortition|
              !sortition.cancelled?
            end
          end
        end
      end
    end
  end
end
