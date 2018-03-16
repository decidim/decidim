# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingHCell < Decidim::Meetings::MeetingCell
      def show
        render
      end

      private

      def resource_date_time
        str = l model.start_time, format: :decidim_day_of_year
        str += " - "
        str += l model.start_time, format: :time_of_day
        str += "-"
        str += l model.end_time, format: :time_of_day
        str
      end
    end
  end
end
