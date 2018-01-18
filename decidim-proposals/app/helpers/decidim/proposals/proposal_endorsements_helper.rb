# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helper to handle markup variations for proposal endorsements partials
    module ProposalEndorsementsHelper
      # Returns the css classes used for proposal endorsements count in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a hash with the css classes for the count number and label
      def endorsements_count_classes(from_proposals_list)
        return { number: "card__support__number", label: "" } if from_proposals_list
        { number: "extra__suport-number", label: "extra__suport-text" }
      end

      # Returns the css classes used for proposal endorsement button in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a string with the value of the css classes.
      def endorsement_button_classes(from_proposals_list)
        return "small" if from_proposals_list
        "expanded button--sc"
      end

      # Public: Checks if endorsement are enabled in this step.
      #
      # Returns true if enabled, false otherwise.
      def endorsements_enabled?
        current_settings.endorsements_enabled
      end

      # Public: Checks if endorsements are blocked in this step.
      #
      # Returns true if blocked, false otherwise.
      def endorsements_blocked?
        current_settings.endorsements_blocked
      end

      # Public: Checks if the current user is allowed to endorse in this step.
      #
      # Returns true if the current user can endorse, false otherwise.
      def current_user_can_endorse?
        current_user && endorsements_enabled? && !endorsements_blocked?
      end

      def endorsement_identity(endorsement)
        endorsement.user_group ? endorsement.user_group : endorsement.author
      end

      # Public: Renders a button to endorse the given proposal.
      #
      # @params (mandatory): proposal, from_proposals_list
      # @params (optional) : user_group, btn_label
      def endorsement_button(proposal, from_proposals_list, btn_label = nil, user_group = nil)
        current_endorsement_url = proposal_proposal_endorsement_path(
          proposal_id: proposal,
          from_proposals_list: from_proposals_list,
          user_group_id: user_group&.id
        )
        # to override the translation for both buttons: endorse and unendorse (use to be the name of the user/user_group)
        endorse_label = btn_label || t(".endorse")
        unendorse_label = btn_label || t("decidim.proposals.proposal_endorsements_helper.endorsement_button.already_endorsed")

        render partial: "decidim/proposals/proposals/endorsement_button", locals: { proposal: proposal,
                                                                                    from_proposals_list: from_proposals_list, user_group: user_group,
                                                                                    current_endorsement_url: current_endorsement_url,
                                                                                    endorse_label: endorse_label, unendorse_label: unendorse_label }
      end
    end
  end
end
