# frozen_string_literal: true

module Decidim
  module Meetings
    module Calendar
      # This class converts the given meeting to an ICalendar event, using the
      # `icalendar` gem.
      #
      # Examples:
      #     meeting = Decidim::Meetings::Meeting.find(params[:id])
      #     converter = MeetingToEvent.new(meeting)
      #     converter.event # => #<Icalendar::Event ...>
      #     converter.to_ical # => "BEGIN:VEVENT\n\r...END:VEVENT\n\r"
      #
      # Note that this event will not be bound to any calendar. If you need to
      # attach it to a calendar, you can do it like this:
      #
      #     calendar = Icalendar::Calendar.new
      #     event = MeetingToEvent.new(meeting).event
      #     calendar.add_event(event)
      #
      class MeetingToEvent
        include ActionView::Helpers::SanitizeHelper

        # Initializes the converteer for the given meeting.
        #
        # meeting - the Meeting to convert
        def initialize(meeting)
          @meeting = meeting
        end

        # Converts the given meeting to an ICalendar event object
        #
        # Returns an ICalendar::Event instance
        def event
          return @event if @event

          @event = Icalendar::Event.new
          @event.dtstart = Icalendar::Values::DateTime.new(meeting.start_time.utc, "tzid" => "UTC")
          @event.dtend = Icalendar::Values::DateTime.new(meeting.end_time.utc, "tzid" => "UTC")
          @event.summary = present(meeting).title
          @event.description = strip_tags(CGI.unescapeHTML(present(meeting).description))
          @event.location = meeting.address
          @event.geo = [meeting.latitude, meeting.longitude]
          @event.url = url_for(meeting)

          @event
        end

        # Converts the given meeting to an ICalendar event representation that
        # follows the specific format.
        #
        # Returns a String
        delegate :to_ical, to: :event

        private

        attr_reader :meeting

        def url_for(meeting)
          Decidim::ResourceLocatorPresenter.new(meeting).url
        end

        def present(meeting)
          Decidim::Meetings::MeetingPresenter.new(meeting)
        end
      end
    end
  end
end
