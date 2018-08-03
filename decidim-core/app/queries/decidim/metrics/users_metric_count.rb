# frozen_string_literal: true

module Decidim
  module Metrics
    class UsersMetricCount < Decidim::MetricCount
      def self.for(organization, counter_field: :cumulative, group_by: :day)
        super(organization, "users", counter_field: counter_field, group_by: group_by)
      end
    end
  end
end
