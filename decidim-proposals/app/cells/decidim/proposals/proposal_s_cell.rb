# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the Search (:s) proposal card
    # for an instance of a Proposal
    class ProposalSCell < Decidim::CardSCell
      private

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/proposals/proposal_metadata"
      end
    end
  end
end
