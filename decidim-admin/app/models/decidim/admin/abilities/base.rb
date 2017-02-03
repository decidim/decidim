# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`. Extended by both the base `Decidim::Ability`
      # class and other engine-only abilities, like the
      # `ParticipatoryProcessAdmin` ability class.
      class Base
        include CanCan::Ability

        def initialize(user, context)
          merge ::Decidim::Ability.new(user, context)
          merge ParticipatoryProcessAdmin.new(user, context)
        end
      end
    end
  end
end
