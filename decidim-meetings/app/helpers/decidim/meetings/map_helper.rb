# frozen_string_literal: true

module Decidim
  module Meetings
    # This helper include some methods for rendering meetings dynamic maps.
    module MapHelper
      include Decidim::SanitizeHelper
      # Serialize a collection of geocoded meetings to be used by the dynamic map component
      #
      # meetings - A collection of meetings
      def meetings_data_for_map(meetings)
        geocoded_meetings = meetings.select(&:geocoded_and_valid?)
        geocoded_meetings.map do |meeting|
          meeting.slice(:latitude, :longitude, :address).merge(title: translated_attribute(meeting.title),
                                                               link: resource_locator(meeting).path,
                                                               items: cell("decidim/meetings/meeting_card_metadata", meeting).send(:meeting_items_for_map).to_json)
        end
      end
    end
  end
end
