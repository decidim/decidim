# frozen_string_literal: true
module Decidim
  module Abilities
    # Defines the base abilities for any user. Guest users will use these too.
    # Intended to be used with `cancancan`.
    class Everyone
      include CanCan::Ability

      def initialize(_user)
        can :read, ParticipatoryProcess do |p|
          p.published?
        end

        can :read, :public_pages
        can :manage, :locales
      end
    end
  end
end
