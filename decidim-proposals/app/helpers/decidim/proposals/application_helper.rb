# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper
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
        end
      end

      def proposal_limit_enabled?
        proposal_limit.present?
      end

      def proposal_limit
        return if feature_settings.proposal_limit.zero?

        feature_settings.proposal_limit
      end

      def current_user_proposals
        Proposal.where(feature: current_feature, author: current_user)
      end
    end
  end
end
