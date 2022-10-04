# frozen_string_literal: true

module Decidim
  module Meetings
    # A cell to display when actions happen on a meeting.
    class MeetingActivityCell < ActivityCell
      def title
        action == "update" ? I18n.t("decidim.meetings.last_activity.meeting_updated") : I18n.t("decidim.meetings.last_activity.new_meeting")
      end

      def resource_link_text
        Decidim::Meetings::MeetingPresenter.new(resource).title
      end
    end
  end
end
