# frozen_string_literal: true

module Decidim
  module Assemblies
    module Metrics
      class AssembliesMetricManage < Decidim::MetricManage
        def initialize(day_string, organization)
          super(day_string, organization)
          @metric_name = "assemblies"
        end

        private

        def query
          return @query if @query

          @query = Decidim::Assembly.where(organization: @organization)
          @query = @query.where("decidim_assemblies.published_at <= ?", end_time)
          @query
        end

        def quantity
          @quantity ||= query.where("decidim_assemblies.published_at >= ?", start_time).count
        end
      end
    end
  end
end
