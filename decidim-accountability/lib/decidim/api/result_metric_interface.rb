# frozen_string_literal: true

module Decidim
  module Accountability
    ResultMetricInterface = GraphQL::InterfaceType.define do
      name "ResultMetricInterface"
      description "ResultMetric definition"

      field :count, !types.Int, "Total results" do
        resolve ->(organization, _args, _ctx) {
          ResultMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          ResultMetricTypeHelper.base_scope(organization).group("date_trunc('day', created_at)").count
        }
      end

      field :data, !types[ResultMetricObjectType], "Data for each result" do
        resolve ->(organization, _args, _ctx) {
          ResultMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
