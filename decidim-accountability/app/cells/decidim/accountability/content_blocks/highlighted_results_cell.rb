# frozen_string_literal: true

module Decidim
  module Accountability
    module ContentBlocks
      class HighlightedResultsCell < Decidim::ContentBlocks::HighlightedElementsCell
        def show
          render unless results_cell.results_count.zero?
        end

        private

        def results_cell
          @results_cell ||= cell(
            "decidim/accountability/highlighted_results_for_component",
            published_components.one? ? published_components.first : published_components,
            order: model.settings.order
          )
        end
      end
    end
  end
end
