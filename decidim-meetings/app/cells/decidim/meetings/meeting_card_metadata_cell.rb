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

      def meeting_items_for_map
        [dates, type, official].compact_blank.map do |item|
          {
            text: item[:text],
            icon: icon(item[:icon]).html_safe
          }
        end
      end

      def dates
        text = if start_time.year != end_time.year
                 "#{l(start_time.to_date, format: :decidim_short_with_month_name_short)} - #{l(end_time.to_date, format: :decidim_short_with_month_name_short)}"
               elsif start_time.month != end_time.month || start_time.day != end_time.day
                 "#{l(start_time.to_date, format: :decidim_with_month_name_short)} - #{l(end_time.to_date, format: :decidim_with_month_name_short)}"
               else
                 "#{l(start_time, format: :time_of_day)} - #{l(end_time, format: :time_of_day)}"
               end

        {
          text:,
          icon: "timer-2-line"
        }
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

      def category_item
        return if category.blank?

        {
          text: category.translated_name,
          icon: resource_type_icon_key("Decidim::Category")
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
