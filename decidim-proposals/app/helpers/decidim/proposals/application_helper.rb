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
        value = if state == "accepted"
                  "accepted"
                elsif state == "rejected"
                  "rejected"
                else
                  "not_answered"
                end

        I18n.t(value, scope: "decidim.proposals.answers")
      end

      # Public: The css class applied based on the proposal state.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def proposal_state_css_class(state)
        if state == "accepted"
          "text-success"
        elsif state == "rejected"
          "text-alert"
        else
          "text-warning"
        end
      end
    end
  end
end
