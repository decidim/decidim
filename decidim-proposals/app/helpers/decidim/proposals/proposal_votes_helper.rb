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
    end
  end
end