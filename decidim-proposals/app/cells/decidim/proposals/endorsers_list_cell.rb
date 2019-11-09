# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the list of endorsers for the given Proposal.
    #
    # Example:
    #
    #    cell("decidim/proposals/endorsers_list", my_proposal)
    class EndorsersListCell < Decidim::ViewModel
      include ProposalCellsHelper

      def show
        return unless endorsers.any?

        render
      end

      private

      # Finds the correct author for each endorsement.
      #
      # Returns an Array of presented Users/UserGroups
      def endorsers
        @endorsers ||= model.endorsements.for_listing.map { |identity| present(identity.normalized_author) }
      end
    end
  end
end
