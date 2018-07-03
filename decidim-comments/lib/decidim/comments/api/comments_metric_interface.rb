# frozen_string_literal: true

module Decidim
  module Comments
    CommentsMetricInterface = GraphQL::InterfaceType.define do
      name "CommentsMetricInterface"
      description "CommentsMetric definition"

      field :count, !types.Int, "Total comments" do
        resolve ->(organization, _args, _ctx) {
          CommentsMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          CommentsMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[CommentsMetricObjectType], "Data for each comment" do
        resolve ->(organization, _args, _ctx) {
          CommentsMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
