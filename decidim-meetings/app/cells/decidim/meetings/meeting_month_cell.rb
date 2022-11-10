# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingMonthCell < Decidim::ViewModel
      alias meetings model

      def month
        @month ||= expanded_month(start_date || first_meeting.start_time)
      end

      def start_date
        options[:start_date]
      end

      def events
        options[:events] || meetings.select { |meeting| meeting.start_time.month == month[0] }.map { |meeting| meeting.start_time.to_date }
      end

      def first_meeting
        @first_meeting ||= meetings.first
      end

      def expanded_month(date)
        [date.month, date.to_date.all_month]
      end
    end
  end
end
