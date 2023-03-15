# frozen_string_literal: true

module Decidim
  module Proposals
    module ContentBlocks
      class HighlightedProposalsCell < Decidim::ContentBlocks::HighlightedElementsWithCellForListCell
        private

        def list_cell_path = "decidim/proposals/highlighted_proposals_for_component"
      end
    end
  end
end
