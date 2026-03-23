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
        return render :static_map
      end

      def year
        l model.start_time, format: "%Y"
      end

      def end_year
        return nil if model.end_time.blank?

        l model.end_time, format: "%Y"
      end

      private

      def same_month?
        return true if end_time.blank?

        start_time.year == end_time.year && start_time.month == end_time.month
      end

      def same_day?
        return true if end_time.blank?

        start_time.to_date == end_time.to_date
      end

      def same_year?
        return true if end_time.blank?

        start_time.year == end_time.year
      end

      def display_map?
        maps_enabled? && !online? && model.address.present?
      end
    end
  end
end
