# frozen_string_literal: true
module Decidim
  module Meetings
    # This helper include some methods for rendering meetings static and dynamic maps.
    module MapHelper
      # Renders a link to openstreetmaps with the meeting latitude and longitude.
      # The link's content is a static map image.
      #
      # meeting - A Decidim::Meetings::Meeting object
      # options - An optional hash of options (default: { zoom: 17 })
      #           * zoom: A number to represent the zoom value of the map
      def static_map_link(meeting, options = {})
        if meeting.geocoded?
          zoom = options[:zoom] || 17
          latitude = meeting.latitude
          longitude = meeting.longitude

          map_url = "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=#{zoom}/#{latitude}/#{longitude}"

          link_to map_url, target: "_blank" do
            image_tag decidim_meetings.static_map_meeting_path(feature_id: meeting.feature,
                                                               participatory_process_id: meeting.feature.participatory_process,
                                                               id: meeting)
          end
        end
      end

      # Serialize a collection of geocoded meetings to be used by the dynamic map component
      #
      # geocoded_meetings - A collection of geocoded meetings
      def meetings_data_for_map(geocoded_meetings)
        geocoded_meetings.map do |meeting|
          meeting.slice(:latitude, :longitude, :address).merge(title: translated_attribute(meeting.title),
                                                               description: translated_attribute(meeting.short_description),
                                                               startTimeDay: l(meeting.start_time, format: "%d"),
                                                               startTimeMonth: l(meeting.start_time, format: "%B"),
                                                               startTime: "#{meeting.start_time.strftime("%H:%M")} - #{meeting.end_time.strftime("%H:%M")}",
                                                               icon: icon("meetings", width: 40, height: 70, remove_icon_class: true),
                                                               location: translated_attribute(meeting.location),
                                                               locationHints: translated_attribute(meeting.location_hints),
                                                               link: meeting_path(meeting))
        end
      end
    end
  end
end
