# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      # Defines the abilities related to initiatives for a logged in user.
      # Intended to be used with `cancancan`.
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :create, Initiative if creation_enabled?
          can :read, Initiative do |initiative|
            initiative.published? || initiative.has_authorship?(user) || user&.admin?
          end

          can :read, :admin_dashboard if has_initiatives?

          define_membership_management_abilities
        end

        private

        def creation_enabled?
          Decidim::Initiatives.creation_enabled && (
            Decidim::Initiatives.do_not_require_authorization ||
              UserAuthorizations.for(user).any? ||
              user.user_groups.verified.any?
          )
        end

        def define_membership_management_abilities
          can :request_membership, Initiative do |initiative|
            !initiative.published? &&
              !initiative.has_authorship?(user) &&
              (
                Decidim::Initiatives.do_not_require_authorization ||
                UserAuthorizations.for(user).any? ||
                user.user_groups.verified.any?
              )
          end
        end

        def has_initiatives?
          initiatives = InitiativesCreated.by(user) | InitiativesPromoted.by(user)
          initiatives.any?
        end
      end
    end
  end
end
