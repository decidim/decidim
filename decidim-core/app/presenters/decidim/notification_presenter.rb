# frozen_string_literal: true

module Decidim
  #
  # Decorator for notifications.
  #
  class NotificationPresenter < SimpleDelegator
    TIME_RANGES = {
      1.minute => :seconds_time,
      1.hour => :minutes_time,
      1.day => :hours_time,
      1.month => :days_time,
      1.year => :long_time
    }.freeze

    def created_at_in_words
      time_range = TIME_RANGES.find { |time, _| created_at.between?(time.ago, Time.current) }
      time_displayer_method = time_range&.last || :default_time
      seconds_elapsed = (Time.current - created_at).ceil

      send(time_displayer_method, seconds_elapsed)
    end

    private

    def seconds_time(seconds_elapsed)
      I18n.t("time.time_in_words_to_now.seconds", count: seconds_elapsed)
    end

    def minutes_time(seconds_elapsed)
      minutes_elapsed = seconds_elapsed / 60
      I18n.t("time.time_in_words_to_now.minutes", count: minutes_elapsed)
    end

    def hours_time(seconds_elapsed)
      hours_elapsed = seconds_elapsed / 3600
      I18n.t("time.time_in_words_to_now.hours", count: hours_elapsed)
    end

    def days_time(seconds_elapsed)
      days_elapsed = seconds_elapsed / 86_400
      I18n.t("time.time_in_words_to_now.days", count: days_elapsed)
    end

    def long_time(_)
      return I18n.l(created_at, format: :ddmm) if created_at.year == Time.current.year

      default_time(created_at)
    end

    def default_time(_)
      I18n.l(created_at, format: :ddmmyyyy)
    end
  end
end
