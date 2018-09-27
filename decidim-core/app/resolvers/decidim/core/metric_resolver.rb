# frozen_string_literal: true

module Decidim
  module Core
    # A GraphQL resolver to handle `count` and `metric` queries
    class MetricResolver
      attr_reader :name

      def initialize(name, organization)
        @name = name
        @organization = organization
        @group_by = :day
        @counter_field = :cumulative
      end

      def count
        metric_scope.max.try(:last) || 0
      end

      def history
        metric_scope
      end

      private

      def metric_scope
        Decidim::Metric
          .where(metric_type: name, organization: organization)
          .group(group_by)
          .order("#{group_by} DESC")
          .limit(60)
          .sum(counter_field)
      end

      attr_reader :organization, :group_by, :counter_field
    end
  end
end
