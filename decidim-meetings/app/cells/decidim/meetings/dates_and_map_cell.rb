# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the meeting dates range and the map if enabled and
    # available
    class DatesAndMapCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::MapHelper

      alias meeting model

      delegate :start_time, :end_time, :maps_enabled?, :online?, to: :meeting
      delegate :snippets, to: :controller

      def static_map
        return render :static_map if display_map?
      end

      private

      def same_month?
        start_time.month == end_time.month
      end

      def same_day?
        start_time.day == end_time.day
      end

      def display_map?
        maps_enabled? && !online?
      end
    end
  end
end
