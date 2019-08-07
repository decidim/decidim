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

        @query = Decidim::User.where(organization: @organization)
        @query = @query.where("created_at <= ?", end_time)
        @query
      end

      def quantity
        @quantity ||= @query.where("created_at >= ?", start_time).count
      end
    end
  end
end
