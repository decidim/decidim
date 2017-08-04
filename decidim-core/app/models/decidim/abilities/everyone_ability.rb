# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the base abilities for any user. Guest users will use these too.
    # Intended to be used with `cancancan`.
    class EveryoneAbility
      include CanCan::Ability

      def initialize(user, _context)
        can :read, :public_pages
        can :manage, :locales

        can :read, Feature, &:published?

        can :search, Scope

        can :manage, User do |other|
          other == user
        end
      end
    end
  end
end
