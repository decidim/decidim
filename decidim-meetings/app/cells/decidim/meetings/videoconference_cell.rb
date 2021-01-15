# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell is used to render an iframe to embed a Jitsi videoconference from a meeting
    class VideoconferenceCell < Decidim::ViewModel
      def visible?
        Time.zone.now.between?(meeting.start_time - 30.minutes, meeting.end_time + 10.minutes)
      end

      def room_name
        @room_name ||= [meeting.reference, token].join.slice(0, 50).gsub(/[\W_]+/, "")
      end

      def iframe_id
        "videoconference-#{meeting.id}"
      end

      def domain
        Decidim.videoconferences.dig(:jitsi, :domain)
      end

      def api_url
        Decidim.videoconferences.dig(:jitsi, :api_url)
      end

      def user_role
        return "admin" if current_user&.admin?
        return "participant" if meeting.can_participate?(current_user)
        return "visitor" if meeting.current_user_can_visit_meeting?(current_user)
      end

      # compatibilize with old versions if no salt available (less secure)
      def token
        if defined?(salt) && salt.present?
          tokenizer = Decidim::Tokenizer.new(salt: salt)
          return tokenizer.hex_digest(meeting.id)
        end

        Digest::SHA1.hexdigest "#{meeting.id}-#{Rails.application.secrets.secret_key_base}"
      end

      def attendance_url
        Decidim::EngineRouter.main_proxy(model.component).meeting_videoconference_attendance_logs_url(meeting_id: meeting.id)
      end

      def meeting
        model
      end

      def organization
        meeting.component.organization
      end
    end
  end
end
