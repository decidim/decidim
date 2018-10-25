# frozen_string_literal: true

module Decidim
  module Meetings
    module Calendar
      # This class serves as a base class to render calendars. Please, inherit
      # from it and overwrite the `render_meeting_events` with whatever logic
      # you need to do it. After that, modify the
      # `Decidim::Meetings::Calendar.for` method to include your new class.
      class BaseCalendar
        # Convenience method to shorten the calls. Converts the resource
        # meetings to the ICalendar format.
        #
        # resource - a resource that has meetings.
        #
        # Returns a String.
        def self.for(resource)
          new(resource).to_ical
        end

        # Initializes the class.
        #
        # resource - a resource that has meetings.
        def initialize(resource)
          @resource = resource
        end

        # Converts the resource meetings to the ICalendar format.
        #
        # Returns a String.
        def to_ical
          <<~CALENDAR.gsub("\n\n", "\n")
            BEGIN:VCALENDAR\r
            VERSION:2.0\r
            PRODID:icalendar-ruby\r
            CALSCALE:GREGORIAN\r
            #{render_meeting_events}
            END:VCALENDAR\r
          CALENDAR
        end

        private

        attr_reader :resource

        # Internal: this method is supposed to be overwritten by classes
        # inheriting from this one. It should find the relevant meetings that
        # will be exported, and convert them to ICalendar events. Please use the
        # `MeetingToEvent` class to do so. Since this method returns a String,
        # you can cache its contents. Check existing implementations for an
        # example of how to achieve it.
        #
        # Returns a String.
        def render_meeting_events
          raise "Please, overwrite this method. You can use the `MeetingToEvent` class to convert a meeting to the correct ICalendar format."
        end
      end
    end
  end
end
