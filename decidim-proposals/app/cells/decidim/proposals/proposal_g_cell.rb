# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the Grid (:g) proposal card
    # for an instance of a Proposal
    class ProposalGCell < Decidim::CardGCell
      private

      def metadata_cell
        "decidim/proposals/proposal_metadata_g"
      end

      def show_description?
        true
      end
    end
  end
end
