# frozen_string_literal: true

module Decidim
  module Comments
    CommentMetricInterface = GraphQL::InterfaceType.define do
      name "CommentMetricInterface"
      description "CommentMetric definition"

      field :count, !types.Int, "Total comments" do
        resolve ->(organization, _args, _ctx) {
          CommentMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          CommentMetricTypeHelper.base_scope(organization).group("date_trunc('day', created_at)").count
        }
      end

      field :data, !types[CommentMetricObjectType], "Data for each comment" do
        resolve ->(organization, _args, _ctx) {
          CommentMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
