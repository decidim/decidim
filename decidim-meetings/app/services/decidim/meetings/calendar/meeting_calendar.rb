# frozen_string_literal: true

module Decidim
  module Meetings
    module Calendar
      # This class handles how to convert a single meeting to the ICalendar
      # format. It caches its result until the meeting is updated again.
      # This class generates a ICalendar entry for an individual meeting.
      class MeetingCalendar < BaseCalendar
        # Renders the meeting in an ICalendar format. It caches the results in
        # Rails' cache.
        #
        # Returns a String.
        def events
          Rails.cache.fetch(cache_key) do
            MeetingToEvent.new(meeting).to_ical
          end
        end

        private

        alias meeting resource

        # Defines the cache key for the given component.
        #
        # Returns a String.
        def cache_key
          "meetings-calendar-meeting-#{meeting.id}-#{meeting.updated_at.to_i}"
        end
      end
    end
  end
end
