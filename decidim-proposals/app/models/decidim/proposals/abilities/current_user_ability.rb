# frozen_string_literal: true

module Decidim
  module Proposals
    module Abilities
      # Defines the abilities related to proposals for a logged in user.
      # Intended to be used with `cancancan`.
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          setup_endorsement_related_abilities
          setup_voting_related_abilities
          can :create, Proposal if authorized?(:create) && creation_enabled?
          can :edit, Proposal do |proposal|
            proposal.editable_by?(user)
          end

          can :withdraw, Proposal do |proposal|
            can_withdraw?(proposal)
          end

          can :report, Proposal
        end

        private

        def setup_endorsement_related_abilities
          can :endorse, Proposal do |_proposal|
            authorized?(:endorse) && endorsements_enabled? && !endorsements_blocked?
          end
          can :unendorse, Proposal do |_proposal|
            authorized?(:unendorse) && endorsements_enabled?
          end
        end

        def setup_voting_related_abilities
          can :vote, Proposal do |_proposal|
            authorized?(:vote) && voting_enabled? && remaining_votes.positive?
          end
          can :unvote, Proposal do |_proposal|
            authorized?(:vote) && voting_enabled?
          end
        end

        def authorized?(action)
          return unless component

          ActionAuthorizer.new(user, component, action).authorize.ok?
        end

        def vote_limit_enabled?
          return unless component_settings
          component_settings.vote_limit.present? && component_settings.vote_limit.positive?
        end

        def creation_enabled?
          return unless current_settings
          current_settings.creation_enabled?
        end

        def remaining_votes
          return 1 unless vote_limit_enabled?

          proposals = Proposal.where(component: component)
          votes_count = ProposalVote.where(author: user, proposal: proposals).size
          component_settings.vote_limit - votes_count
        end

        def endorsements_enabled?
          return unless current_settings
          current_settings.endorsements_enabled?
        end

        def endorsements_blocked?
          return unless current_settings
          current_settings.endorsements_blocked?
        end

        def voting_enabled?
          return unless current_settings
          current_settings.votes_enabled? && !current_settings.votes_blocked?
        end

        def current_settings
          context.fetch(:current_settings, nil)
        end

        def component_settings
          context.fetch(:component_settings, nil)
        end

        def component
          component = context.fetch(:current_component, nil)
          return nil unless component && component.manifest.name == :proposals

          component
        end

        def can_withdraw?(proposal)
          proposal.decidim_author_id == @user.id
        end
      end
    end
  end
end
