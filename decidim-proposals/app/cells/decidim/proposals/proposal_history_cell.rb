# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell is used to render the proposal history panel of a resource
    # inside a tab of a show view
    #
    # The `model` must be a resource to get the proposal history from.and is expected to
    # respond to proposal history method
    #
    # Example:
    #
    #   cell(
    #     "decidim/proposal_history",
    #     meeting
    #   )
    class ProposalHistoryCell < Decidim::ViewModel
      def show
        render
      end
    end
  end
end
