# frozen_string_literal: true

module Decidim
  # This class execute some measures related to Metrics, and return its results
  #
  #  - day: Date object
  #  - resource: Object used to make measurements. Object class is dependant within each measure
  class MetricMeasure
    def self.for(day, resource)
      new(day, resource)
    end

    def initialize(day, resource)
      @day = day.presence || Time.zone.today - 1.day
      raise ArgumentError, "[ERROR] Malformed `day` argument. Format must be `YYYY-MM-DD` and in the past" if @day > Time.zone.today
      @day ||= Time.zone.today - 1.day
      @resource = resource
    end

    def valid?
      @day.present? && @resource.present?
    end

    # this method must be overwritten for each Measure class
    def calculate
      raise StandardError, "Not implemented"
    end

    private

    def start_time
      @start_time ||= @day.beginning_of_day
    end

    def end_time
      @end_time ||= @day.end_of_day
    end
  end
end
