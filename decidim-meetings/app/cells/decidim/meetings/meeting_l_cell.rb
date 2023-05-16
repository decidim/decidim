# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the List (:l) meeting card
    # for an instance of a Meeting
    class MeetingLCell < Decidim::CardLCell
      delegate :component_settings, to: :controller

      alias meeting model

      def has_image?
        true
      end

      def extra_class
        "card__calendar-list__reset"
      end

      def image
        render
      end

      private

      def metadata_cell
        "decidim/meetings/meeting_card_metadata"
      end
    end
  end
end
