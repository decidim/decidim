# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helper to handle markup variations for proposal adhesions partials
    module ProposalAdhesionsHelper
      # Returns the css classes used for proposal adhesions count in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a hash with the css classes for the count number and label
      def adhesions_count_classes(from_proposals_list)
        return { number: "card__support__number", label: "" } if from_proposals_list
        { number: "extra__suport-number", label: "extra__suport-text" }
      end

      # Returns the css classes used for proposal adhesion button in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a string with the value of the css classes.
      def adhesion_button_classes(from_proposals_list)
        return "small" if from_proposals_list
        "expanded button--sc"
      end

      # Public: Checks if adhesions are enabled in this step.
      #
      # Returns true if enabled, false otherwise.
      def adhesions_enabled?
        current_settings.adhesions_enabled
      end

      # Public: Checks if adhesions are blocked in this step.
      #
      # Returns true if blocked, false otherwise.
      def adhesions_blocked?
        current_settings.adhesions_blocked
      end

      # Public: Checks if the current user is allowed to adhere in this step.
      #
      # Returns true if the current user can adhere, false otherwise.
      def current_user_can_adhere?
        current_user && adhesions_enabled? && !adhesions_blocked?
      end

    end
  end
end
