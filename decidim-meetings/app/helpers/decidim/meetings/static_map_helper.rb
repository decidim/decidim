module Decidim
  module Meetings
    module StaticMapHelper
      def static_map_image_tag(meeting)
        if meeting.geocoded?
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
