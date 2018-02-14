# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposal votes partials
    module ProposalVotesHelper
      # Returns the css classes used for proposal votes count in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a hash with the css classes for the count number and label
      def votes_count_classes(from_proposals_list)
        return { number: "card__support__number", label: "" } if from_proposals_list
        { number: "extra__suport-number", label: "extra__suport-text" }
      end

      # Returns the css classes used for proposal vote button in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a string with the value of the css classes.
      def vote_button_classes(from_proposals_list)
        return "small" if from_proposals_list
        "expanded button--sc"
      end

      # Public: Gets the vote limit for each user, if set.
      #
      # Returns an Integer if set, nil otherwise.
      def vote_limit
        return nil if feature_settings.vote_limit.zero?
        feature_settings.vote_limit
      end

      # Check if the vote limit is enabled for the current feature
      #
      # Returns true if the vote limit is enabled
      def vote_limit_enabled?
        vote_limit.present?
      end

      # Public: Checks if maximum votes per proposal are set.
      #
      # Returns true if set, false otherwise.
      def maximum_votes_per_proposal_enabled?
        maximum_votes_per_proposal.present?
      end

      # Public: Fetches the maximum amount of votes per proposal.
      #
      # Returns an Integer with the maximum amount of votes, nil otherwise.
      def maximum_votes_per_proposal
        return nil unless feature_settings.maximum_votes_per_proposal.positive?
        feature_settings.maximum_votes_per_proposal
      end

      # Public: Checks if voting is enabled in this step.
      #
      # Returns true if enabled, false otherwise.
      def votes_enabled?
        current_settings.votes_enabled
      end

      # Public: Checks if voting is blocked in this step.
      #
      # Returns true if blocked, false otherwise.
      def votes_blocked?
        current_settings.votes_blocked
      end

      # Public: Checks if the current user is allowed to vote in this step.
      #
      # Returns true if the current user can vote, false otherwise.
      def current_user_can_vote?
        current_user && votes_enabled? && vote_limit_enabled? && !votes_blocked?
      end

      # Return the remaining votes for a user if the current feature has a vote limit
      #
      # user - A User object
      #
      # Returns a number with the remaining votes for that user
      def remaining_votes_count_for(user)
        return 0 unless vote_limit_enabled?
        proposals = Proposal.where(feature: current_feature)
        votes_count = ProposalVote.where(author: user, proposal: proposals).size
        feature_settings.vote_limit - votes_count
      end
    end
  end
end
