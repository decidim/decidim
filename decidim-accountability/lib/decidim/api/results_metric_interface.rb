# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricInterface = GraphQL::InterfaceType.define do
      name "ResultsMetricInterface"
      description "ResultsMetric definition"

      field :count, !types.Int, "Total results" do
        resolve ->(organization, _args, _ctx) {
          ResultsMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          ResultsMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[ResultsMetricObjectType], "Data for each result" do
        resolve ->(organization, _args, _ctx) {
          ResultsMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
