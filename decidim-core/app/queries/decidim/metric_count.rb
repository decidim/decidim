# frozen_string_literal: true

module Decidim
  # This query counts registered users from a collection of organizations
  # in an optional interval of time.
  class MetricCount < Rectify::Query
    def self.for(organization, metric, counter_type: :count, counter_field: :cumulative, group_by: :day)
      new(organization, metric, counter_type: counter_type, counter_field: counter_field, group_by: group_by).query
    end

    def initialize(organization, metric, counter_type: :count, counter_field: :cumulative, group_by: :day)
      @organization = organization
      @metric = metric
      @counter_type = counter_type
      @counter_field = counter_field
      @group_by = group_by
    end

    def query
      query = Decidim::Metric.where(metric_type: @metric, organization: @organization)
      case @counter_type
      when :count
        query.group(@group_by).sum(@counter_field).max.try(:last) || 0
      when :metric
        query.group(@group_by).sum(@counter_field)
      end
    end
  end
end
