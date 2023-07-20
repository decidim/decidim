# frozen_string_literal: true

module Decidim
  module Elections
    module ContentBlocks
      class RelatedElectionsCell < Decidim::ContentBlocks::HighlightedElementsWithCellForListCell
        private

        def list_cell_path = "decidim/elections/highlighted_elections_for_component"
      end
    end
  end
end
