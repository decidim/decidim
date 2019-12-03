# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helper to handle markup variations for proposal endorsements partials
    module ProposalEndorsementsHelper
      # Returns the css classes used for proposal endorsement button in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a string with the value of the css classes.
      def endorsement_button_classes(from_proposals_list)
        return "small" if from_proposals_list

        "small compact light button--sc expanded"
      end

      def endorsement_identity_presenter(endorsement)
        if endorsement.user_group
          Decidim::UserGroupPresenter.new(endorsement.user_group)
        else
          Decidim::UserPresenter.new(endorsement.author)
        end
      end

      # Public: Renders a button to endorse the given proposal.
      # To override the translation for both buttons: endorse and unendorse (use to be the name of the user/user_group).
      #
      # @params (mandatory): proposal, from_proposals_list
      # @params (optional) : user_group, btn_label
      def endorsement_button(proposal, from_proposals_list, btn_label = nil, user_group = nil)
        current_endorsement_url = proposal_proposal_endorsement_path(
          proposal_id: proposal,
          from_proposals_list: from_proposals_list,
          user_group_id: user_group&.id
        )
        endorse_label = btn_label || t("decidim.proposals.proposal_endorsements_helper.endorsement_button.endorse")
        unendorse_label = btn_label || t("decidim.proposals.proposal_endorsements_helper.endorsement_button.already_endorsed")

        render partial: "decidim/proposals/proposals/endorsement_button", locals: { proposal: proposal,
                                                                                    from_proposals_list: from_proposals_list, user_group: user_group,
                                                                                    current_endorsement_url: current_endorsement_url,
                                                                                    endorse_label: endorse_label, unendorse_label: unendorse_label }
      end

      # Public: Renders an identity for endorsement.
      #
      # @params (mandatory): proposal, from_proposals_list
      # @params (mandatory): user, the user that is endorsing at the end.
      # @params (optional) : user_group, the user_group on behalf of which the endorsement is being done
      def render_endorsement_identity(proposal, user, user_group = nil)
        current_endorsement_url = proposal_proposal_endorsement_path(
          proposal_id: proposal,
          from_proposals_list: false,
          user_group_id: user_group&.id,
          authenticity_token: form_authenticity_token
        )
        presenter = if user_group
                      Decidim::UserGroupPresenter.new(user_group)
                    else
                      Decidim::UserPresenter.new(user)
                    end
        selected = proposal.endorsed_by?(user, user_group)
        http_method = selected ? :delete : :post
        render partial: "decidim/proposals/proposal_endorsements/identity", locals:
        { identity: presenter, selected: selected, current_endorsement_url: current_endorsement_url, http_method: http_method }
      end

    end
  end
end
