# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for User's registries
    class BlockedUsersMetricManage < Decidim::MetricManage
      def metric_name
        "blocked_users"
      end

      private

      def query
        return @query if @query

        @query = Decidim::User.blocked.where(organization: @organization)
        @query = @query.where("blocked_at <= ?", end_time)
        @query
      end

      def quantity
        @quantity ||= @query.where("blocked_at >= ?", start_time).count
      end
    end
  end
end
