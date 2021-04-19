# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for User's registries
    class UserReportsMetricManage < Decidim::MetricManage
      def metric_name
        "user_reports"
      end

      private

      def query
        return @query if @query

        @query = Decidim::User.where(organization: @organization).joins(:user_reports)
        @query = @query.where("#{Decidim::UserReport.table_name}.created_at <= ?", end_time)
        @query
      end

      def quantity
        @quantity ||= @query.where("#{Decidim::UserReport.table_name}.created_at >= ?", start_time).count
      end
    end
  end
end
