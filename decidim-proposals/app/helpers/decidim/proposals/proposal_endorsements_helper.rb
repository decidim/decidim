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

      # Public: Checks if the card for endorsements should be rendered.
      #
      # Returns true if the endorsements card should be rendered, false otherwise.
      def show_endorsements_card?
        endorsements_enabled?
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

      #
      # Public: Checks if the given Proposal has been endorsed by all identities of the user.
      #
      # @param proposal: The Proposal from which endorsements will be checked against.
      # @param user:     The user whose identities and endorsements  will be checked against.
      #
      def fully_endorsed?(proposal, user)
        return false unless user

        user_group_endorsements = user.user_groups.verified.all? { |user_group| proposal.endorsed_by?(user, user_group) }

        user_group_endorsements && proposal.endorsed_by?(user)
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

      # Renders the counter of endorsements that appears in card at show Propoal.
      def render_endorsements_count_card_part(proposal, fully_endorsed)
        content = icon("bullhorn", class: "icon--small", aria_label: "Endorsements", role: "img")
        content += proposal.proposal_endorsements_count.to_s
        tag_params = { id: "proposal-#{proposal.id}-endorsements-count", class: "button small compact light button--sc button--shadow #{fully_endorsed ? "success" : "secondary"}" }
        if proposal.proposal_endorsements_count.positive?
          link_to "#list-of-endorsements", tag_params do
            content
          end
        else
          content_tag("div", tag_params) do
            content
          end
        end
      end

      def render_endorsements_button_card_part(proposal, fully_endorsed)
        endorse_translated = t("decidim.proposals.proposal_endorsements_helper.render_endorsements_button_card_part.endorse")
        if current_settings.endorsements_blocked? || !current_component.participatory_space.can_participate?(current_user)
          content_tag :span, endorse_translated, class: "card__button button #{endorsement_button_classes(false)} disabled", disabled: true, title: endorse_translated
        elsif current_user && allowed_to?(:endorse, :proposal, proposal: proposal)
          render partial: "endorsement_identities_cabin", locals: { proposal: proposal, fully_endorsed: fully_endorsed }
        elsif current_user
          button_to(endorse_translated, proposal_path(proposal),
                    data: { open: "authorizationModal", "open-url": modal_path(:endorse, proposal) },
                    class: "card__button button #{endorsement_button_classes(false)} secondary")
        else
          action_authorized_button_to :endorse, endorse_translated, "", resource: proposal, class: "card__button button #{endorsement_button_classes(false)} secondary"
        end
      end
    end
  end
end
