# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`. Extended by both the base `Decidim::Ability`
      # class and other engine-only abilities, like the
      # `ParticipatoryProcessAdmin` ability class.
      class BaseAbility
        include CanCan::Ability

        def initialize(user, context)
          Decidim.admin_abilities.each do |ability|
            merge ability.constantize.new(user, context)
          end
        end
      end
    end
  end
end
