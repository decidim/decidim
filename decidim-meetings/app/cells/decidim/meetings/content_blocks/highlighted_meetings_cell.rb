# frozen_string_literal: true

module Decidim
  module Meetings
    module ContentBlocks
      class HighlightedMeetingsCell < Decidim::ContentBlocks::HighlightedElementsCell
        def show
          render unless meetings_cell.meetings_count.zero?
        end

        private

        def meetings_cell
          @meetings_cell ||= cell(
            "decidim/meetings/highlighted_meetings_for_component",
            published_components.one? ? published_components.first : published_components
          )
        end
      end
    end
  end
end
