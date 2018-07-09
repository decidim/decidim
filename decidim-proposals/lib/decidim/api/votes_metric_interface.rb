# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricInterface = GraphQL::InterfaceType.define do
      name "VotesMetricInterface"
      description "VotesMetric definition"

      field :count, !types.Int, "Total votes" do
        resolve ->(_obj, _args, ctx) {
          VotesMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          VotesMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
