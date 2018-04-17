# frozen_string_literal: true

module Decidim
  module Proposals
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Proposals::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :proposal

        case permission_action.action
        when :create
          can_create_proposal?
        when :edit
          can_edit_proposal?
        when :withdraw
          can_withdraw_proposal?
        when :endorse
          can_endorse_proposal?
        when :unendorse
          can_unendorse_proposal?
        when :vote
          can_vote_proposal?
        when :unvote
          can_unvote_proposal?
        when :report
          true
        end

        permission_action
      end

      private

      def proposal
        @proposal ||= context.fetch(:proposal, nil)
      end

      def voting_enabled?
        return unless current_settings
        current_settings.votes_enabled? && !current_settings.votes_blocked?
      end

      def vote_limit_enabled?
        return unless component_settings
        component_settings.vote_limit.present? && component_settings.vote_limit.positive?
      end

      def remaining_votes
        return 1 unless vote_limit_enabled?

        proposals = Proposal.where(component: component)
        votes_count = ProposalVote.where(author: user, proposal: proposals).size
        component_settings.vote_limit - votes_count
      end

      def can_create_proposal?
        toggle_allow(authorized?(:create) && current_settings&.creation_enabled?)
      end

      def can_edit_proposal?
        toggle_allow(proposal && proposal.editable_by?(user))
      end

      def can_withdraw_proposal?
        toggle_allow(proposal && proposal.author == user)
      end

      def can_endorse_proposal?
        is_allowed = proposal &&
                     authorized?(:endorse) &&
                     current_settings&.endorsements_enabled? &&
                     !current_settings&.endorsements_blocked?

        toggle_allow(is_allowed)
      end

      def can_unendorse_proposal?
        is_allowed = proposal &&
                     authorized?(:endorse) &&
                     current_settings&.endorsements_enabled?

        toggle_allow(is_allowed)
      end

      def can_vote_proposal?
        is_allowed = proposal &&
                     authorized?(:vote) &&
                     voting_enabled? &&
                     remaining_votes.positive?

        toggle_allow(is_allowed)
      end

      def can_unvote_proposal?
        is_allowed = proposal &&
                     authorized?(:vote) &&
                     voting_enabled?

        toggle_allow(is_allowed)
      end
    end
  end
end
