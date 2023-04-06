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
        @query ||= Decidim::User.where(organization: @organization).not_deleted.not_blocked.confirmed.where("created_at <= ?", end_time)
      end

      def quantity
        @quantity ||= query.where("created_at >= ?", start_time).count
      end
    end
  end
end
