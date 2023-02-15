# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the List (:l) proposal card
    # for an instance of a Proposal
    class ProposalLCell < Decidim::CardLCell
      delegate :component_settings, to: :controller

      alias proposal model

      def extra_class
        "proposal-list-item"
      end

      def title
        present(proposal).title(html_escape: true)
      end

      private

      def metadata_cell
        "decidim/proposals/proposal_card_metadata"
      end
    end
  end
end
