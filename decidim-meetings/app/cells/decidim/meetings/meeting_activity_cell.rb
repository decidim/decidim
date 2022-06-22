# frozen_string_literal: true

module Decidim
  module Meetings
    # A cell to display when actions happen on a meeting.
    class MeetingActivityCell < ActivityCell
      def title
        I18n.t(
          action_key,
          scope: "decidim.meetings.last_activity"
        )
      end

      def action_key
        action == "update" ? "meeting_updated" : "new_meeting"
      end

      def resource_link_text
        Decidim::Meetings::MeetingPresenter.new(resource).title
      end
    end
  end
end
