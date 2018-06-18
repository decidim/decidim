# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalMetricInterface = GraphQL::InterfaceType.define do
      name "AcceptedProposalMetricInterface"
      description "ProposalMetric definition for accepted proposals"

      field :count, !types.Int, "Total accepted proposals"

      field :data, !types[ProposalMetricObjectType], "Data for each accepted proposal"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
