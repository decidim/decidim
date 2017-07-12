# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers used in meetings views
    module MeetingsHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper

      # Public: truncates the meeting description
      #
      # meeting - a Decidim::Meeting instance
      # max_length - a number to limit the length of the description
      #
      # Returns the meeting's description truncated.
      def meeting_description(meeting, max_length = 120)
        link = decidim_meetings.meeting_path(meeting, feature_id: meeting.feature, participatory_process_id: meeting.feature.participatory_process)
        description = translated_attribute(meeting.description)
        tail = "... #{link_to(t('read_more', scope: "decidim.meetings"), link)}".html_safe
        CGI.unescapeHTML html_truncate(description, max_length: max_length, tail: tail)
      end
    end
  end
end
