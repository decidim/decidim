# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalsMetricInterface = GraphQL::InterfaceType.define do
      name "AcceptedProposalsMetricInterface"
      description "ProposalsMetric definition for accepted proposals"

      field :count, !types.Int, "Total accepted proposals" do
        resolve ->(_obj, _args, ctx) {
          AcceptedProposalsMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          AcceptedProposalsMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      field :data, !types[ProposalsMetricObjectType], "Data for each proposal" do
        resolve ->(_obj, _args, ctx) {
          AcceptedProposalsMetricTypeHelper.base_scope(ctx[:current_organization], :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
