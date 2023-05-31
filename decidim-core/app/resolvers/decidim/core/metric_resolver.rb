# frozen_string_literal: true

module Decidim
  module Core
    # A GraphQL resolver to handle `count` and `metric` queries
    class MetricResolver
      attr_reader :name

      #
      # - name: name identifier of metric
      # - organization: Decidim::Organization scoping
      # - filters: hash of attr - value to filter results
      #
      def initialize(name, organization, filters = {})
        @name = name
        @organization = organization
        @filters = filters
        @group_by = :day
        @counter_field = :cumulative
      end

      def count
        resolve.max.try(:last) || 0
      end

      def history
        resolve
      end

      private

      def resolve
        return @records if @records

        scope
        filter
        group
        sum
        @records
      end

      def scope
        @records = Decidim::Metric
                   .where(metric_type: name, organization:)
      end

      # Only key name attributes in Decidim::Metric will be applied
      def filter
        @filters.each do |key, value|
          next unless Decidim::Metric.column_names.include? key.to_s

          @records = @records.where("#{key}": value)
        end
      end

      def group
        @records = @records
                   .group(group_by)
                   .order(Arel.sql("#{group_by} DESC").to_s)
      end

      def sum
        @records = @records
                   .limit(60)
                   .sum(counter_field)
      end

      attr_reader :organization, :filters, :group_by, :counter_field
    end
  end
end
