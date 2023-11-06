# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingMonthCell < Decidim::ViewModel
      alias meetings model

      delegate :month, to: :start_date

      def show
        render if meetings_in_this_month?
      end

      def meetings_in_this_month?
        meetings.collect(&:start_time).map { |date| date.strftime("%m").to_i }.any? month
      end

      def month_days
        start_date.to_date.all_month
      end

      def weeks
        month_days.group_by do |day|
          (1 - first_week_date_rotation).days.since(day).cweek
        end.values
      end

      def month_name
        @month_name ||= I18n.t("date.month_names")[month]
      end

      def abbr_day_names
        @abbr_day_names ||= I18n.t("date.abbr_day_names").rotate(first_week_date_rotation)
      end

      def day_names
        @day_names ||= I18n.t("date.day_names").rotate(first_week_date_rotation)
      end

      def first_day_of_month?(date)
        date.day == 1
      end

      def day_class(date)
        return "is-today" if date == Date.current
        return if events.exclude?(date)

        "is-#{date < Date.current ? "past" : "upcoming"}-event"
      end

      def beginning_of_week
        @beginning_of_week ||= options[:beginning_of_week] || Date.beginning_of_week
      end

      def start_date
        options[:start_date] || first_meeting.start_time
      end

      def events
        options[:events] || meetings.select { |meeting| meeting.start_time.month == month }.map { |meeting| meeting.start_time.to_date }
      end

      def first_meeting
        @first_meeting ||= meetings.first
      end

      def first_week_date_rotation
        @first_week_date_rotation ||= Date::DAYS_INTO_WEEK[beginning_of_week.to_sym].to_i
      end
    end
  end
end
