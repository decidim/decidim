# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders metadata for an instance of a Meeting
    class MeetingCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias meeting model

      delegate :type_of_meeting, :start_time, :end_time, :category, :withdrawn?, to: :meeting

      def initialize(*)
        super

        @items.prepend(*meeting_items)
      end

      private

      def meeting_items
        [type, category_item, duration, comments_count_item, official, withdrawn_item]
      end

      def type
        {
          text: t(type_of_meeting, scope: "decidim.meetings.meetings.filters.type_values"),
          icon: resource_type_icon_key(type_of_meeting)
        }
      end

      def duration
        return if [start_time, end_time].any?(&:blank?)

        {
          text: distance_of_time_in_words(start_time, end_time, scope: "datetime.distance_in_words.short"),
          icon: "time-line"
        }
      end

      def official
        return unless official?

        {
          text: t("decidim.meetings.models.meeting.fields.official_meeting"),
          icon: "information-line"
        }
      end

      def withdrawn_item
        return unless withdrawn?

        {
          text: t("withdraw", scope: "decidim.meetings.types"),
          icon: resource_type_icon_key("withdrawn")
        }
      end
    end
  end
end
