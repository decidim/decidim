# frozen_string_literal: true
module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper

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

      # Public: Returns a proposals url merging current params with order
      def order_link(order)
        link_to t(".#{order}"), url_for(params.to_unsafe_h.merge(order: order)), remote: true
      end
    end
  end
end
