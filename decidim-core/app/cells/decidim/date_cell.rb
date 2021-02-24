# frozen_string_literal: true

module Decidim
  # This cell renders a date or a date range
  # the `model` is expected to be an hash with two keys:
  #  `start` is the starting datetime
  #  `end` is the ending datetime
  # both are optional
  #
  # {
  #   start: model.start_time,
  #   end: model.end_time
  # }
  #
  class DateCell < Decidim::ViewModel
    include Decidim::IconHelper

    def show
      return unless start_time && end_time

      render :show
    end

    private

    def start_time
      model[:start]
    end

    def end_time
      model[:end]
    end

    def same_day?
      start_time.beginning_of_day == end_time.beginning_of_day
    end

    def same_year?
      start_time.beginning_of_year == end_time.beginning_of_year
    end

    def show_year?
      !same_year? || !current_year?(start_time) || !current_year?(end_time)
    end

    def current_year?(time)
      time.year == Time.zone.now.year
    end
  end
end
