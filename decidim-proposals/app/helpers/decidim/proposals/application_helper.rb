# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper
      include ProposalEndorsementsHelper
      include Decidim::MapHelper
      include Decidim::Proposals::MapHelper

      # Public: The state of a proposal in a way a human can understand.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def humanize_proposal_state(state)
        I18n.t(state, scope: "decidim.proposals.answers", default: :not_answered)
      end

      # Public: The css class applied based on the proposal state.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def proposal_state_css_class(state)
        case state
        when "accepted"
          "text-success"
        when "rejected"
          "text-alert"
        when "evaluating"
          "text-info"
        else
          "text-warning"
        end
      end

      # Public: The css class applied based on the proposal state to
      #         the proposal badge.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def proposal_state_badge_css_class(state)
        case state
        when "accepted"
          "success"
        when "rejected"
          "warning"
        when "evaluating"
          "secondary"
        when "withdrawn"
          "alert"
        end
      end

      def proposal_limit_enabled?
        proposal_limit.present?
      end

      def proposal_limit
        return if component_settings.proposal_limit.zero?

        component_settings.proposal_limit
      end

      def current_user_proposals
        Proposal.where(component: current_component, author: current_user)
      end

      def follow_button_for(model)
        if current_user
          render partial: "decidim/shared/follow_button", locals: { followable: model }
        else
          content_tag(:p, class: "mt-s mb-none") do
            t("decidim.proposals.proposals.show.sign_in_or_up",
              in: link_to(t("decidim.proposals.proposals.show.sign_in"), decidim.new_user_session_path),
              up: link_to(t("decidim.proposals.proposals.show.sign_up"), decidim.new_user_registration_path)).html_safe
          end
        end
      end

      # Public - A widget that lists all identities in an xxs card format.
      # Shows the first 5 identities and hides the rest, but presents a 'see all'
      # button to make the rest of identities visible.
      #
      # @param identities: The list of identities. Each item must have a user_group or author method.
      # @param widget_id: Mandatory when placing more than 1 widget in a page, optional otherwise. Is the id
      #   uniquely identify this widget in the page.
      #
      def identities_list_xxs(identities, widget_id = "identities-xxs")
        widget_ids = {
          ellipsis: "#{widget_id}-ellipsis",
          remaining_identities: "#{widget_id}-remaining-identities",
          see_all_identities: "#{widget_id}-see-all-identities"
        }
        render partial: "identities_listing", locals: { identities: identities, widget_ids: widget_ids }
      end

      def identities_xxs(identities)
        identities.collect do |identity|
          render partial: "identity_xxs", locals: { identity: identity.normalized_author }
        end.join(", ").html_safe
      end
    end
  end
end
