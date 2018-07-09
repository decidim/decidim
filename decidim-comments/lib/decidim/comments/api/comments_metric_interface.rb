# frozen_string_literal: true

module Decidim
  module Comments
    CommentsMetricInterface = GraphQL::InterfaceType.define do
      name "CommentsMetricInterface"
      description "CommentsMetric definition"

      field :count, !types.Int, "Total comments" do
        resolve ->(_obj, _args, ctx) {
          CommentsMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          CommentsMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
