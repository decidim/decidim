# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposal votes partials
    module ProposalVotesHelper
      delegate :minimum_votes_per_user, to: :component_settings

      # Check if the vote limit is enabled for the current component
      #
      # Returns true if the vote limit is enabled
      def vote_limit_enabled?
        vote_limit.present?
      end

      def minimum_votes_per_user_enabled?
        minimum_votes_per_user.positive?
      end

      # Public: Checks if threshold per proposal are set.
      #
      # Returns true if set, false otherwise.
      def threshold_per_proposal_enabled?
        threshold_per_proposal.present?
      end

      # Public: Fetches the maximum amount of votes per proposal.
      #
      # Returns an Integer with the maximum amount of votes, nil otherwise.
      def threshold_per_proposal
        return nil unless component_settings.threshold_per_proposal&.positive?

        component_settings.threshold_per_proposal
      end

      # Public: Checks if can accumulate more than maximum is enabled
      #
      # Returns true if enabled, false otherwise.
      def can_accumulate_votes_beyond_threshold?
        component_settings.can_accumulate_votes_beyond_threshold
      end

      # Public: Checks if voting is enabled in this step.
      #
      # Returns true if enabled, false otherwise.
      def votes_enabled?
        current_settings.respond_to?(:votes_enabled) && current_settings.votes_enabled
      end

      # Public: Checks if voting is blocked in this step.
      #
      # Returns true if blocked, false otherwise.
      def votes_blocked?
        current_settings.respond_to?(:votes_blocked) && current_settings.votes_blocked
      end

      # Public: Checks if the current user is allowed to vote in this step.
      #
      # Returns true if the current user can vote, false otherwise.
      def current_user_can_vote?
        current_user && votes_enabled? && vote_limit_enabled? && !votes_blocked?
      end

      def proposal_voted_by_user?(proposal)
        return false if current_user.blank? || proposal.blank?

        all_voted_proposals_by_user.include?(proposal.id)
      end

      # Return the remaining votes for a user if the current component has a vote limit
      #
      # user - A User object
      #
      # Returns a number with the remaining votes for that user
      def remaining_votes_count_for_user
        return 0 unless vote_limit_enabled?

        component_settings.vote_limit - votes_given
      end

      # Return the remaining minimum votes for a user if the current component has a vote limit
      #
      # user - A User object
      #
      # Returns a number with the remaining minimum votes for that user
      def remaining_minimum_votes_count_for_user
        return 0 unless minimum_votes_per_user_enabled?

        component_settings.minimum_votes_per_user - votes_given
      end

      private

      def votes_given
        @votes_given ||= all_voted_proposals_by_user.length
      end

      # Gets the vote limit for each user, if set.
      #
      # Returns an Integer if set, nil otherwise.
      def vote_limit
        return nil if component_settings.vote_limit&.zero?

        component_settings.vote_limit
      end

      def all_voted_proposals_by_user
        return [] if current_user.blank?

        @all_voted_proposals ||= ProposalVote.where(
          proposal: Proposal.where(component: current_component),
          author: current_user
        ).pluck(:decidim_proposal_id)
      end
    end
  end
end
