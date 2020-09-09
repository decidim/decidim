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
        geocoded_meetings = meetings.select(&:geocoded?)
        geocoded_meetings.map do |meeting|
          meeting.slice(:latitude, :longitude, :address).merge(title: translated_attribute(meeting.title),
                                                               description: translated_attribute(meeting.description),
                                                               startTimeDay: l(meeting.start_time, format: "%d"),
                                                               startTimeMonth: l(meeting.start_time, format: "%B"),
                                                               startTimeYear: l(meeting.start_time, format: "%Y"),
                                                               startTime: "#{meeting.start_time.strftime("%H:%M")} - #{meeting.end_time.strftime("%H:%M")}",
                                                               icon: icon("meetings", width: 40, height: 70, remove_icon_class: true),
                                                               location: translated_attribute(meeting.location),
                                                               locationHints: decidim_html_escape(translated_attribute(meeting.location_hints)),
                                                               link: resource_locator(meeting).path,
                                                               markerColor: event_pin_color(meeting))
        end
      end

      def event_pin_color(meeting)
        organization = meeting.component.organization
        colors = organization.colors

        return colors["primary"] unless organization.group_highlight_enabled?
        return colors.fetch("official_highlight_color", colors["primary"]) if meeting.official?
        return colors.fetch("group_highlight_color", colors["primary"]) if meeting.group?

        colors.fetch("citizen_highlight_color", colors["primary"])
      end
    end
  end
end
