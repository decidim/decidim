# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsMetricInterface = GraphQL::InterfaceType.define do
      name "PorposalsMetricInterface"
      description "ProposalsMetric definition"

      field :count, !types.Int, "Total proposals" do
        resolve ->(_obj, _args, ctx) {
          ProposalsMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          ProposalsMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      field :data, !types[ProposalsMetricObjectType], "Data for each proposal" do
        resolve ->(_obj, _args, ctx) {
          ProposalsMetricTypeHelper.base_scope(ctx[:current_organization], :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
