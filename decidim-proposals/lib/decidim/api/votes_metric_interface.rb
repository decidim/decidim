# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricInterface = GraphQL::InterfaceType.define do
      name "VotesMetricInterface"
      description "VotesMetric definition"

      field :count, !types.Int, "Total votes" do
        resolve ->(organization, _args, _ctx) {
          VotesMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          VotesMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[VotesMetricObjectType], "Data for each vote" do
        resolve ->(organization, _args, _ctx) {
          VotesMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
