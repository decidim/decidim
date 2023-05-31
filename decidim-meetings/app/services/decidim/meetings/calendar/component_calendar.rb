# frozen_string_literal: true

module Decidim
  module Meetings
    module Calendar
      # This class handles how to convert a component meetings to the ICalendar
      # format. It caches its result until the component is updated again.
      class ComponentCalendar < BaseCalendar
        # Renders the meetings in an ICalendar format. It caches the results in
        # Rails' cache.
        #
        # Returns a String.
        def events
          filtered_meetings.map do |meeting|
            MeetingCalendar.new(meeting).events
          end.compact.join
        end

        private

        alias component resource

        # Finds the component meetings.
        #
        # Returns a collection of Meetings.
        def meetings
          Decidim::Meetings::Meeting.where(component:)
        end

        # Finds the component meetings.
        #
        # Returns a collection of Meetings filtered based on provided params.
        def filtered_meetings
          meetings.not_hidden.published.except_withdrawn.ransack(@filters).result
        end
      end
    end
  end
end
