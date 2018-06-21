# frozen_string_literal: true

module Decidim
  module Core
    UserMetricInterface = GraphQL::InterfaceType.define do
      name "UserMetricInterface"
      description "UserMetric definition"

      field :count, !types.Int, "Total users" do
        resolve ->(organization, _args, _ctx) {
          UserMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          UserMetricTypeHelper.base_scope(organization).group("date_trunc('day', confirmed_at)").count
        }
      end

      field :data, !types[UserMetricObjectType], "Data for each user" do
        resolve ->(organization, _args, _ctx) {
          UserMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
