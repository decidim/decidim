# frozen_string_literal: true

module Decidim
  module Proposals
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?
        return false unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Proposals::Admin::Permissions.new(user, permission_action, context).allowed? if permission_action.scope == :admin
        return false if permission_action.scope != :public

        return false if permission_action.subject != :proposal

        return true if case permission_action.action
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
                       else
                         false
                       end

        false
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
        authorized?(:create) &&
          current_settings&.creation_enabled?
      end

      def can_edit_proposal?
        proposal &&
          proposal.editable_by?(user)
      end

      def can_withdraw_proposal?
        proposal &&
          proposal.author == user
      end

      def can_endorse_proposal?
        proposal &&
          authorized?(:endorse) &&
          current_settings&.endorsements_enabled? &&
          !current_settings&.endorsements_blocked?
      end

      def can_unendorse_proposal?
        proposal &&
          authorized?(:endorse) &&
          current_settings&.endorsements_enabled?
      end

      def can_vote_proposal?
        proposal &&
          authorized?(:vote) &&
          voting_enabled? &&
          remaining_votes.positive?
      end

      def can_unvote_proposal?
        proposal &&
          authorized?(:vote) &&
          voting_enabled?
      end
    end
  end
end
