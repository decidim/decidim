# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingMonthCell < Decidim::ViewModel
      def month
        options[:month]
      end

      def events
        options[:events] || []
      end
    end
  end
end
