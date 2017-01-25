module Decidim
  module Meetings
    module MapHelper
      def static_map_link(meeting, options = {})
        if meeting.geocoded?
          zoom = options[:zoom] || 17
          latitude = meeting.latitude
          longitude = meeting.longitude

          map_url = "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=#{zoom}/#{latitude}/#{longitude}"

          link_to map_url, target: "_blank" do
            image_tag decidim_meetings.static_map_meeting_path({
              feature_id: meeting.feature,
              participatory_process_id: meeting.feature.participatory_process,
              id: meeting
            })
          end
        end
      end

      def meetings_data_for_map(meetings)
        meetings.select(&:geocoded?).map do |meeting|
          meeting.slice(:latitude, :longitude, :address).merge({
            title: translated_attribute(meeting.title),
            description: translated_attribute(meeting.short_description),
            startTimeDay: l(meeting.start_time, format: "%d"),
            startTimeMonth: l(meeting.start_time, format: "%B"),
            startTime: "#{meeting.start_time.strftime("%H:%M")} - #{meeting.end_time.strftime("%H:%M")}",
            icon: icon("meetings", width: 40, height: 70, remove_icon_class: true),
            location: translated_attribute(meeting.location),
            locationHints: translated_attribute(meeting.location_hints),
            link: meeting_path(meeting)
          })
        end.to_json
      end
    end
  end
end
