# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the highlighted meetings for a given component.
    # It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedMeetingsForComponentCell < Decidim::ViewModel
      include Decidim::ComponentPathHelper
      include Decidim::CardHelper

      def show
        render unless meetings_count.zero?
      end

      private

      def meetings
        @meetings ||= Decidim::Meetings::Meeting.where(component: model)
      end

      def past_meetings
        @past_meetings ||= meetings.past.order(end_time: :desc, start_time: :desc).limit(3)
      end

      def upcoming_meetings
        @upcoming_meetings ||= meetings.upcoming.order(:start_time, :end_time).limit(3)
      end

      def meetings_count
        @meetings_count ||= meetings.count
      end
    end
  end
end
