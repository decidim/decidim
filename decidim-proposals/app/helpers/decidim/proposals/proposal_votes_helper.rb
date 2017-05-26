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

      # Check if the vote limit is enabled for the current feature
      #
      # Returns true if the vote limit is enabled
      def vote_limit_enabled?
        current_user && current_settings.votes_enabled? && feature_settings.vote_limit.present? && feature_settings.vote_limit.positive?
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
