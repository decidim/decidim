# frozen_string_literal: true

module Decidim
  module Meetings
    module ContentBlocks
      class HighlightedMeetingsCell < Decidim::ContentBlocks::HighlightedElementsWithCellForListCell
        private

        def list_cell_path = "decidim/meetings/highlighted_meetings_for_component"
      end
    end
  end
end
