# frozen_string_literal: true
module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper
      include ProposalOrderHelper
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
    end
  end
end
