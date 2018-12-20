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
          Rails.cache.fetch(cache_key) do
            meetings.map do |meeting|
              MeetingToEvent.new(meeting).to_ical
            end.join
          end
        end

        private

        alias component resource

        # Finds the component meetings.
        #
        # Returns a collection of Meetings.
        def meetings
          Decidim::Meetings::Meeting.where(component: component)
        end

        # Defines the cache key for the given component.
        #
        # Returns a String.
        def cache_key
          "meetings-calendar-component-#{component.id}-#{component.updated_at.to_i}"
        end
      end
    end
  end
end
