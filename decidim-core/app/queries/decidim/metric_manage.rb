# frozen_string_literal: true

module Decidim
  # This class search for objects related to Metrics, and creates a new registry within
  # his own parameters
  class MetricManage
    def self.for(day_string, organization)
      new(day_string, organization)
    end

    def initialize(day_string, organization)
      @day = day_string.present? ? Date.parse(day_string) : Time.zone.today - 1.day
      raise ArgumentError, "[ERROR] Malformed `day` argument. Format must be `YYYY-MM-DD` and in the past" if @day > Time.zone.today
      @day ||= Time.zone.today - 1.day
      @organization = organization
      @metric_name = ""
    end

    def valid?
      @day.present?
    end

    def save
      return @registry if @registry

      return if cumulative.zero?
      @registry = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name, organization: @organization)
      @registry.assign_attributes(cumulative: cumulative, quantity: quantity)
      @registry.save!
      @registry
    end

    private

    def start_time
      @start_time ||= @day.beginning_of_day
    end

    def end_time
      @end_time ||= @day.end_of_day
    end

    def query
      raise "Not implemented"
    end

    def cumulative
      @cumulative ||= query.count
    end

    def quantity
      @quantity ||= cumulative
    end
  end
end
