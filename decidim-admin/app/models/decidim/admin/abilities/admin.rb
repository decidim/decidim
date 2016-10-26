module Decidim
  module Admin
    module Abilities
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
