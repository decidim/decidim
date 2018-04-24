# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to user able to administer initiative types.
        # Intended to be used with `cancancan`.
        class InitiativeTypeAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user&.admin?

            @user = user
            @context = context

            can :manage, InitiativesType
            cannot :destroy, InitiativesType
            can :destroy, InitiativesType do |initiative_type|
              result = true

              initiative_type.scopes.each do |s|
                result &&= s.initiatives.empty?
              end

              result
            end

            can :manage, Decidim::InitiativesTypeScope
            cannot :destroy, Decidim::InitiativesTypeScope
            can :destroy, Decidim::InitiativesTypeScope do |scope|
              scope.initiatives.empty?
            end
          end
        end
      end
    end
  end
end
