# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsMetricInterface = GraphQL::InterfaceType.define do
      name "PorposalsMetricInterface"
      description "ProposalsMetric definition"

      field :count, !types.Int, "Total proposals" do
        resolve ->(organization, _args, _ctx) {
          ProposalsMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          ProposalsMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[ProposalsMetricObjectType], "Data for each proposal" do
        resolve ->(organization, _args, _ctx) {
          ProposalsMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
