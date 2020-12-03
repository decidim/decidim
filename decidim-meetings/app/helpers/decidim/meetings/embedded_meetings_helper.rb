# frozen_string_literal: true

module Decidim
  module Meetings
    # This helper include some methods for business logic in embedded videoconferences.
    module EmbeddedMeetingsHelper
      def embedded_meeting(meeting, user)
        content_tag :div, nil, id: "jitsi-embedded-meeting", data: {
            room_name: embedded_meeting_room_name(meeting),
            domain: embedded_meeting_domain,
            api_url: embedded_meeting_api_url,
            user_email: user&.email,
            user_display_name: user&.name,
            user_is_visitor: embedded_meeting_role_for(meeting, user) == "visitor"
          }
      end

      def embedded_meeting_room_name(meeting)
        Digest::SHA1.hexdigest "#{meeting.id}-#{meeting.start_time}-#{Rails.application.secrets.secret_key_base}"
      end

      def embedded_meeting_open?(meeting)
        Time.zone.now.between?(meeting.start_time - 30.minutes, meeting.end_time + 10.minutes) # TODO make configurable
      end

      def embedded_meeting_role_for(meeting, user)
        if meeting.can_participate?(user)
          "participant"
        elsif meeting.current_user_can_visit_meeting?(user)
          "visitor"
        else
          "none"
        end
      end

      def embedded_meeting_api_url # TODO make configurable
        "https://meet.jit.si/external_api.js"
      end

      def embedded_meeting_domain # TODO make configurable
        "meet.jit.si"
      end
    end
  end
end
