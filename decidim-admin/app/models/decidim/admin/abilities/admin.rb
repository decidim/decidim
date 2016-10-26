# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`.
      class Admin
        include CanCan::Ability

        def initialize(user)
          return unless user.role?(:admin)

          can :manage, Decidim::ParticipatoryProcess
          can :manage, Decidim::ParticipatoryProcessStep
        end
      end
    end
  end
end
