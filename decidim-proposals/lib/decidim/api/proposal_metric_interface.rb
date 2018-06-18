# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalMetricInterface = GraphQL::InterfaceType.define do
      name "PorposalMetricInterface"
      description "ProposalMetric definition"

      field :count, !types.Int, "Total proposals"

      field :data, !types[ProposalMetricObjectType], "Data for each proposal"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
