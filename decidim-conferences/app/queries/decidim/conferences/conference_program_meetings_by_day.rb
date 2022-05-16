# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters meetings for component and day
    class ConferenceProgramMeetingsByDay < Decidim::Query
      def initialize(component, day, user = nil)
        @component = component
        @day = day
        @user = user
      end

      def query
        Decidim::Query.merge(
          ConferenceProgramMeetings.new(@component, @user)
        ).query.where(start_time: @day.all_day).order(start_time: :asc)
      end
    end
  end
end
