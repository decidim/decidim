# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the Search (:s) meeting card
    # for a given instance of a Meeting
    class MeetingSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/meetings/meeting_card_metadata"
      end
    end
  end
end
