# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.meetings.last_activity.new_meeting_at_html",
          link: link_to(
            translated_attribute(model.component.participatory_space.title),
            resource_locator(model.component.participatory_space).path
          )
        )
      end
    end
  end
end
