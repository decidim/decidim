# frozen_string_literal: true

require "active_support/core_ext/date_time/calculations"
require "active_support/concern"

module Decidim
  # A concern to render friendlier dates
  module FriendlyDates
    extend ActiveSupport::Concern

    # Returns the creation date in a friendly relative format.
    def friendly_created_at
      current_datetime = Time.current

      if created_at > current_datetime.beginning_of_day
        I18n.l(created_at, format: :time_of_day)
      elsif created_at > current_datetime.beginning_of_week
        I18n.l(created_at, format: :day_of_week)
      elsif created_at > current_datetime.beginning_of_year
        I18n.l(created_at, format: :day_of_month)
      else
        I18n.l(created_at, format: :day_of_year)
      end
    end
  end
end
