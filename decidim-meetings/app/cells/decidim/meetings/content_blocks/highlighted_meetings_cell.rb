# frozen_string_literal: true

module Decidim
  module Meetings
    module ContentBlocks
      class HighlightedMeetingsCell < Decidim::ContentBlocks::HighlightedElementsWithCellForListCell
        private

        def list_cell_path
          "decidim/meetings/highlighted_meetings_for_component"
        end

        def see_all_path
          meetings_directory_path if model.scope_name == "homepage"
        end

        def meetings_directory_path
          Decidim::Meetings::DirectoryEngine.routes.url_helpers.root_path
        end
      end
    end
  end
end
