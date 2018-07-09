# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricInterface = GraphQL::InterfaceType.define do
      name "ResultsMetricInterface"
      description "ResultsMetric definition"

      field :count, !types.Int, "Total results" do
        resolve ->(_obj, _args, ctx) {
          ResultsMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          ResultsMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
