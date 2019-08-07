# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the highlighted meetings for a given participatory
    # space. It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedMeetingsCell < Decidim::ViewModel
      include MeetingCellsHelper

      private

      def published_components
        Decidim::Component
          .where(
            participatory_space: model,
            manifest_name: :meetings
          )
          .published
      end
    end
  end
end
