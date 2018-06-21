# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalMetricInterface = GraphQL::InterfaceType.define do
      name "PorposalMetricInterface"
      description "ProposalMetric definition"

      field :count, !types.Int, "Total proposals" do
        resolve ->(organization, _args, _ctx) {
          ProposalMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          ProposalMetricTypeHelper.base_scope(organization).group("date_trunc('day', published_at)").count
        }
      end

      field :data, !types[ProposalMetricObjectType], "Data for each proposal" do
        resolve ->(organization, _args, _ctx) {
          ProposalMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
