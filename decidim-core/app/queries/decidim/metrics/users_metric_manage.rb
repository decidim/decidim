# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for User's registries
    class UsersMetricManage < Decidim::MetricManage
      def metric_name
        "users"
      end

      private

      def query
        return @query if @query

        @query = Decidim::User
        @query = @query.where("confirmed_at <= ?", end_time).not_managed.confirmed
        @query
      end

      def quantity
        @quantity ||= @query.where("confirmed_at >= ?", start_time).count
      end
    end
  end
end
