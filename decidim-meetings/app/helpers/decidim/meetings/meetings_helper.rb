# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers used in meetings views
    module MeetingsHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper

      # Public: truncates the meeting description
      #
      # meeting - a Decidim::Meeting instance
      # max_length - a number to limit the length of the description
      #
      # Returns the meeting's description truncated.
      def meeting_description(meeting, max_length = 120)
        link = resource_locator(meeting).path
        description = translated_attribute(meeting.description)
        tail = "... #{link_to(t("read_more", scope: "decidim.meetings"), link)}".html_safe
        CGI.unescapeHTML html_truncate(description, max_length: max_length, tail: tail)
      end

      def meeting_type_badge_css_class(type)
        case type
        when "private"
          "alert"
        when "transparent"
          "secondary"
        end
      end

      def humanize_meeting_type(type)
        I18n.t(type, scope: "decidim.meetings.types", default: :is_transparent)
      end
    end
  end
end
