# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for User's registries
    class SuspendedUsersMetricManage < Decidim::MetricManage
      def metric_name
        "suspended_users"
      end

      private

      def query
        return @query if @query

        @query = Decidim::User.where(organization: @organization, suspended: true)
        @query
      end

      def quantity
        @quantity ||= @query.count
      end
    end
  end
end
