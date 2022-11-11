# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders metadata for an instance of a Meeting
    class MeetingCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper

      alias meeting model

      def initialize(*)
        super

        @items.prepend(*meeting_items)
      end

      private

      def meeting_items
        [type, duration, official]
      end

      def type
        type = meeting.type_of_meeting
        {
          text: t(type, scope: "decidim.meetings.meetings.filters.type_values"),
          icon: resource_type_icon_key(type)
        }
      end

      def duration
        {
          text: "2h",
          icon: "time-line"
        }
      end

      def official
        {
          text: t("decidim.meetings.models.meeting.fields.official_meeting"),
          icon: "information-line"
        }
      end
    end
  end
end
