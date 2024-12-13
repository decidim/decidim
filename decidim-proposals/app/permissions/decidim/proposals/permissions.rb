# frozen_string_literal: true

module Decidim
  module Proposals
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Proposals::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        toggle_allow(!proposal.hidden?) if permission_action.subject == :proposal && permission_action.action == :read
        return permission_action unless user

        case permission_action.subject
        when :proposal
          apply_proposal_permissions(permission_action) unless permission_action.action == :read
        when :collaborative_draft
          apply_collaborative_draft_permissions(permission_action)
        when :proposal_coauthor_invites
          apply_proposal_coauthor_invites(permission_action)
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
        when :amend
          can_create_amendment?
        when :vote
          can_vote_proposal?
        when :unvote
          can_unvote_proposal?
        when :report
          true
        end
      end

      def proposal
        @proposal ||= context.fetch(:proposal, nil) || context.fetch(:resource, nil)
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

        proposals = Proposal.where(component:)
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

      def can_create_amendment?
        is_allowed = proposal &&
                     authorized?(:amend, resource: proposal) &&
                     current_settings&.amendments_enabled?

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
        when :react_to_request_access
          can_react_to_request_access_collaborative_draft?
        end
      end

      def collaborative_draft
        @collaborative_draft ||= context.fetch(:collaborative_draft, nil)
      end

      def collaborative_drafts_enabled?
        component_settings.collaborative_drafts_enabled
      end

      def can_create_collaborative_draft?
        return toggle_allow(false) unless collaborative_drafts_enabled?

        toggle_allow(current_settings&.creation_enabled? && authorized?(:create))
      end

      def can_edit_collaborative_draft?
        return toggle_allow(false) unless collaborative_drafts_enabled? && collaborative_draft.open?

        toggle_allow(collaborative_draft.editable_by?(user))
      end

      def can_publish_collaborative_draft?
        return toggle_allow(false) unless collaborative_drafts_enabled? && collaborative_draft.open?

        toggle_allow(collaborative_draft.created_by?(user))
      end

      def can_request_access_collaborative_draft?
        return toggle_allow(false) unless collaborative_drafts_enabled? && collaborative_draft.open?
        return toggle_allow(false) if collaborative_draft.requesters.include?(user)

        toggle_allow(!collaborative_draft.editable_by?(user))
      end

      def can_react_to_request_access_collaborative_draft?
        return toggle_allow(false) unless collaborative_drafts_enabled? && collaborative_draft.open?
        return toggle_allow(false) if collaborative_draft.requesters.include? user

        toggle_allow(collaborative_draft.created_by?(user))
      end

      def apply_proposal_coauthor_invites(permission_action)
        return toggle_allow(false) unless coauthor
        return toggle_allow(false) unless proposal

        case permission_action.action
        when :invite
          toggle_allow(valid_coauthor? && !notification_already_sent?)
        when :cancel
          toggle_allow(valid_coauthor? && notification_already_sent?)
        when :accept, :decline
          toggle_allow(can_be_coauthor?)
        end
      end

      def coauthor
        context.fetch(:coauthor, nil)
      end

      def notification_already_sent?
        @notification_already_sent ||= proposal.coauthor_invitations_for(coauthor).any?
      end

      def coauthor_in_comments?
        @coauthor_in_comments ||= proposal.comments.where(author: coauthor).any?
      end

      def valid_coauthor?
        return false unless proposal.authors.include?(user)
        return false unless proposal.user_has_actions?(coauthor)

        coauthor_in_comments?
      end

      def can_be_coauthor?
        return false unless user == coauthor
        return false unless proposal.user_has_actions?(coauthor)

        notification_already_sent?
      end
    end
  end
end
