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

      def year
        l model.start_time, format: "%Y"
      end

      def display_start_and_end_time?
        model.respond_to?(:start_time) && model.respond_to?(:end_time)
      end

      def start_and_end_time
        <<~HTML
          #{with_tooltip(l(model.start_time, format: :tooltip)) { format_start_time }}
          -
          #{with_tooltip(l(model.end_time, format: :tooltip)) { format_end_time }}
        HTML
      end

      private

      def format_start_time
        l model.start_time, format: "%H:%M %p"
      end

      def format_end_time
        l model.end_time, format: "%H:%M %p %Z"
      end

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
