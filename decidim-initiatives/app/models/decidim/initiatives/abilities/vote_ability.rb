# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      # Defines the abilities related to votes.
      # Intended to be used with `cancancan`.
      class VoteAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :vote, Initiative do |initiative|
            can_vote?(initiative)
          end

          can :unvote, Initiative do |initiative|
            can_unvote?(initiative)
          end
        end

        private

        def decidim_user_group_id
          context[:params]&.try(:[], "group_id")
        end

        def can_vote?(initiative)
          initiative.votes_enabled? &&
            initiative.organization&.id == user.organization&.id &&
            initiative.votes.where(decidim_author_id: user.id, decidim_user_group_id: decidim_user_group_id).empty? &&
            (can_user_support?(initiative) || user.user_groups.verified.any?)
        end

        def can_unvote?(initiative)
          initiative.votes_enabled? &&
            initiative.organization&.id == user.organization&.id &&
            initiative.votes.where(decidim_author_id: user.id, decidim_user_group_id: decidim_user_group_id).any? &&
            (can_user_support?(initiative) || user.user_groups.verified.any?)
        end

        def can_user_support?(initiative)
          !initiative.offline? && (
            Decidim::Initiatives.do_not_require_authorization ||
            UserAuthorizations.for(user).any?
          )
        end
      end
    end
  end
end
