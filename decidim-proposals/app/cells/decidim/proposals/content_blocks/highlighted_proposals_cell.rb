# frozen_string_literal: true

module Decidim
  module Proposals
    module ContentBlocks
      class HighlightedProposalsCell < Decidim::ContentBlocks::HighlightedElementsCell
        def show
          render unless proposals_cell.proposals_count.zero?
        end

        private

        def proposals_cell
          @proposals_cell ||= cell(
            "decidim/proposals/highlighted_proposals_for_component",
            published_components.one? ? published_components.first : published_components,
            order: model.settings.order
          )
        end
      end
    end
  end
end
