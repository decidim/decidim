# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to admin users able to administer
        # promotal committee membership requests.
        # Intended to be used with `cancancan`.
        class CommitteeAdminAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user&.admin?

            @user = user
            @context = context

            can :manage_membership, Decidim::Initiative
            can :index, InitiativesCommitteeMember

            can :approve, InitiativesCommitteeMember do |request|
              !request.accepted?
            end

            can :revoke, InitiativesCommitteeMember do |request|
              !request.rejected?
            end
          end
        end
      end
    end
  end
end
