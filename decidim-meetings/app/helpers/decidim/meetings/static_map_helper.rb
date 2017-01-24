module Decidim
  module Meetings
    module StaticMapHelper
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
    end
  end
end
