# frozen_string_literal: true

module Decidim
  module Proposals
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Proposals::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        if permission_action.subject == :proposal
          apply_proposal_permissions(permission_action)
        elsif permission_action.subject == :collaborative_draft
          apply_collaborative_draft_permissions(permission_action)
        else
          permission_action
        end

        permission_action
      end

      private

      def apply_proposal_permissions(permission_action)
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
      end

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
        toggle_allow(proposal && proposal.authored_by?(user))
      end

      def can_endorse_proposal?
        is_allowed = proposal &&
                     authorized?(:endorse, resource: proposal) &&
                     current_settings&.endorsements_enabled? &&
                     !current_settings&.endorsements_blocked?

        toggle_allow(is_allowed)
      end

      def can_unendorse_proposal?
        is_allowed = proposal &&
                     authorized?(:endorse, resource: proposal) &&
                     current_settings&.endorsements_enabled?

        toggle_allow(is_allowed)
      end

      def can_vote_proposal?
        is_allowed = proposal &&
                     authorized?(:vote, resource: proposal) &&
                     voting_enabled? &&
                     remaining_votes.positive?

        toggle_allow(is_allowed)
      end

      def can_unvote_proposal?
        is_allowed = proposal &&
                     authorized?(:vote, resource: proposal) &&
                     voting_enabled?

        toggle_allow(is_allowed)
      end

      def apply_collaborative_draft_permissions(permission_action)
        case permission_action.action
        when :create
          can_create_collaborative_draft?
        when :edit
          can_edit_collaborative_draft?
        when :publish
          can_publish_collaborative_draft?
        when :request_access
          can_request_access_collaborative_draft?
        end
      end

      def collaborative_draft
        @collaborative_draft ||= context.fetch(:collaborative_draft, nil)
      end

      def can_create_collaborative_draft?
        toggle_allow(authorized?(:create) && current_settings&.creation_enabled? && component_settings&.collaborative_drafts_enabled?)
      end

      def can_edit_collaborative_draft?
        toggle_allow(collaborative_draft.open? && collaborative_draft.editable_by?(user) && component_settings&.collaborative_drafts_enabled?)
      end

      def can_publish_collaborative_draft?
        toggle_allow(collaborative_draft.open? && collaborative_draft.editable_by?(user) && component_settings&.collaborative_drafts_enabled?)
      end

      def can_request_access_collaborative_draft?
        return toggle_allow(false) unless collaborative_draft.open? && component_settings&.collaborative_drafts_enabled?
        return toggle_allow(false) if collaborative_draft.editable_by?(user)
        return toggle_allow(false) if collaborative_draft.requesters.include? user
        toggle_allow(collaborative_draft && !collaborative_draft.editable_by?(user))
      end
    end
  end
end
