# frozen_string_literal: true

module Decidim
  module Proposals
    class Permissions
      def initialize(user, permission_action, context)
        @user = user
        @permission_action = permission_action
        @context = context
      end

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

      attr_reader :user, :permission_action, :context

      def spaces_allows_user?
        return unless space.manifest.permissions_class
        space.manifest.permissions_class.new(user, permission_action, context).allowed?
      end

      def current_settings
        @current_settings ||= context.fetch(:current_settings, nil)
      end

      def component_settings
        @component_settings ||= context.fetch(:component_settings, nil)
      end

      def component
        @component ||= context.fetch(:current_component)
      end

      def space
        @space ||= component.participatory_space
      end

      def proposal
        @proposal ||= context.fetch(:proposal, nil)
      end

      def authorized?(permission_action)
        return unless component

        ActionAuthorizer.new(user, component, permission_action).authorize.ok?
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
