# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      # Defines the abilities for non logged users..
      # Intended to be used with `cancancan`.
      class NonLoggedUserAbility
        include CanCan::Ability

        attr_reader :context

        def initialize(user, context)
          return if user

          @context = context

          can :create, Initiative if creation_enabled?
          can :vote, Initiative
          can :request_membership, Initiative do |initiative|
            !initiative.published?
          end
        end

        private

        def creation_enabled?
          Decidim::Initiatives.creation_enabled
        end
      end
    end
  end
end
