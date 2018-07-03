# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricInterface = GraphQL::InterfaceType.define do
      name "UsersMetricInterface"
      description "UsersMetric definition"

      field :count, !types.Int, "Total users" do
        resolve ->(organization, _args, _ctx) {
          UsersMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          UsersMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[UsersMetricObjectType], "Data for each user" do
        resolve ->(organization, _args, _ctx) {
          UsersMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
