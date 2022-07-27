# frozen_string_literal: true

module Decidim
  module Meetings
    # A cell to display when actions happen on a meeting.
    class MeetingActivityCell < ActivityCell
      def title
        case action
        when "update"
          I18n.t(
            "decidim.meetings.last_activity.meeting_updated_at_html",
            link: participatory_space_link
          )
        else
          I18n.t(
            "decidim.meetings.last_activity.new_meeting_at_html",
            link: participatory_space_link
          )
        end
      end

      def resource_link_text
        presenter.title
      end

      def description
        strip_tags(presenter.description(links: true))
      end

      def presenter
        @presenter ||= Decidim::Meetings::MeetingPresenter.new(resource)
      end
    end
  end
end
