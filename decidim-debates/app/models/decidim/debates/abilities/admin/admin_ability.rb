# frozen_string_literal: true

module Decidim
  module Debates
    module Abilities
      module Admin
        # Defines the abilities related to debates for an admin user.
        # Intended to be used with `cancancan`.
        class AdminAbility < Decidim::Abilities::AdminAbility
          def define_abilities
            can :manage, Debate do |debate|
              debate.author.blank?
            end
            can :unreport, Debate
            can :hide, Debate
          end
        end
      end
    end
  end
end
