# frozen_string_literal: true

require "active_support/core_ext/date_time/calculations"

module Decidim
  # A Helper to render dates
  module DatetimeHelper
    # Renders a date in the simplest possible format.
    def simple_date(datetime)
      current_datetime = Time.zone.now

      if datetime > current_datetime.beginning_of_day
        I18n.l(datetime, format: :time_of_day)
      elsif datetime > current_datetime.beginning_of_week
        I18n.l(datetime, format: :day_of_week)
      elsif datetime > current_datetime.beginning_of_year
        I18n.l(datetime, format: :day_of_month)
      else
        I18n.l(datetime, format: :day_of_year)
      end
    end
  end
end
