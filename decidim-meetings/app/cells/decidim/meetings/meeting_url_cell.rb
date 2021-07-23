# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the URL address of an online meeting.
    class MeetingUrlCell < Decidim::Meetings::OnlineMeetingCell
      include Cell::ViewModel::Partial
      include LayoutHelper

      private

      def resource_icon
        icon icon_name, class: "icon--big", role: "img", "aria-hidden": true
      end

      def icon_name
        if has_meeting_url?
          "video"
        else
          "timer"
        end
      end

      def has_meeting_url?
        @has_meeting_url ||= model.online_meeting_url.present?
      end
    end
  end
end
