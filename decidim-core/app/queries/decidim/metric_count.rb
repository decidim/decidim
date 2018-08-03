# frozen_string_literal: true

module Decidim
  # This class search for Metric registries, within some parameters, then return a
  # final counter or hashed metric data
  class MetricCount
    def self.for(organization, metric, counter_field: :cumulative, group_by: :day)
      new(organization, metric, counter_field: counter_field, group_by: group_by)
    end

    def initialize(organization, metric, counter_field: :cumulative, group_by: :day)
      @organization = organization
      @metric = metric
      @counter_field = counter_field
      @group_by = group_by
      @query = Decidim::Metric.where(metric_type: @metric, organization: @organization)
    end

    def metric
      @query.group(@group_by).sum(@counter_field)
    end

    def count
      metric.max.try(:last) || 0
    end
  end
end
