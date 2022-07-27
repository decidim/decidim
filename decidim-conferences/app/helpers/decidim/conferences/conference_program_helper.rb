# frozen_string_literal: true

module Decidim
  module Conferences
    # Helpers related to the Conferences layout.
    module ConferenceProgramHelper
      include Decidim::ResourceHelper

      def meetings_for_day(component, day, user)
        meetings = Decidim::Conferences::ConferenceProgramMeetingsByDay.new(component, day, user).query

        meetings_by_time = {}
        meetings.each do |meeting|
          meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] ||= []
          meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] << { meeting: }
        end
        meetings_by_time
      end
    end
  end
end
