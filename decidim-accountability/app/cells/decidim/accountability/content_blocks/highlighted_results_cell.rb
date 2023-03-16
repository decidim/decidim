# frozen_string_literal: true

module Decidim
  module Accountability
    module ContentBlocks
      class HighlightedResultsCell < Decidim::ContentBlocks::HighlightedElementsWithCellForListCell
        private

        def list_cell_path = "decidim/accountability/highlighted_results_for_component"
      end
    end
  end
end
