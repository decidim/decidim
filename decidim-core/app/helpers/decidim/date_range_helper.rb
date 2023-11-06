# frozen_string_literal: true

module Decidim
  # Helper to format date ranges
  module DateRangeHelper
    def format_date_range(start_date, end_date)
      return if [start_date, end_date].any?(&:blank?)

      format = [start_date.year, end_date.year].any? { |year| year != Date.current.year } ? :decidim_short_with_month_name_short : :decidim_with_month_name_short
      if start_date.to_date == end_date.to_date && start_date.to_time == end_date.to_time
        l(start_date.to_date, format:)
      elsif start_date.to_date == end_date.to_date
        "#{l(start_date.to_date, format:)} #{l(start_date, format: :time_of_day)} → #{l(end_date, format: :time_of_day)}".html_safe
      else
        "#{l(start_date.to_date, format:)} → #{l(end_date.to_date, format:)}".html_safe
      end
    end
  end
end
