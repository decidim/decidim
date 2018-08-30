# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for User's registries
    class UsersMetricManage < Decidim::MetricManage
      def initialize(day_string, organization)
        super(day_string, organization)
        @metric_name = "users"
        @query = Decidim::User
      end

      private

      def query
        @query = @query.where("confirmed_at <= ?", end_time).not_managed.confirmed
      end

      def quantity
        @quantity ||= @query.where("confirmed_at >= ?", start_time).count
      end
    end
  end
end
