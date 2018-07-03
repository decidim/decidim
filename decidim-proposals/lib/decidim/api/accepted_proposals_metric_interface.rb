# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalsMetricInterface = GraphQL::InterfaceType.define do
      name "AcceptedProposalsMetricInterface"
      description "ProposalsMetric definition for accepted proposals"

      field :count, !types.Int, "Total accepted proposals" do
        resolve ->(organization, _args, _ctx) {
          AcceptedProposalsMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          AcceptedProposalsMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[ProposalsMetricObjectType], "Data for each proposal" do
        resolve ->(organization, _args, _ctx) {
          AcceptedProposalsMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
