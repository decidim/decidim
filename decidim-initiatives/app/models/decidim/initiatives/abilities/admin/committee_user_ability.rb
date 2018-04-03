# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to plain users able to administer
        # promotal committee membership requests.
        # Intended to be used with `cancancan`.
        class CommitteeUserAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user
            return if user&.admin?

            @user = user
            @context = context

            can :manage_membership, Decidim::Initiative do |initiative|
              initiative.has_authorship?(user)
            end

            can :index, InitiativesCommitteeMember if has_initiatives?(user)
            can :approve, InitiativesCommitteeMember do |request|
              request.initiative.has_authorship?(user) &&
                !request.initiative.published? &&
                !request.accepted?
            end

            can :revoke, InitiativesCommitteeMember do |request|
              request.initiative.has_authorship?(user) &&
                !request.initiative.published? &&
                !request.rejected?
            end
          end

          private

          def has_initiatives?(user)
            initiatives = InitiativesCreated.by(user) | InitiativesPromoted.by(user)
            initiatives.any?
          end
        end
      end
    end
  end
end
