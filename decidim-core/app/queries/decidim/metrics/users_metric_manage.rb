# frozen_string_literal: true

module Decidim
  module Metrics
    class UsersMetricManage < Decidim::MetricManage
      def initialize(day_string)
        super(day_string)
        @metric_name = "users"
      end

      def with_context(organization)
        @query = Decidim::User
        super(organization)
      end

      def query
        @query = @query.where("confirmed_at <= ?", @end_date).not_managed.confirmed
      end

      def quantity
        @quantity ||= @query.where("confirmed_at >= ?", @start_date).count
      end
    end
  end
end
