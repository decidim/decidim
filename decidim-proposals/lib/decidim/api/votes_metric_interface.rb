# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricInterface = GraphQL::InterfaceType.define do
      name "ProposalMetricInterface"
      description "VotesMetric definition"

      field :count, !types.Int, "Total votes"

      field :data, !types[VotesMetricObjectType], "Data for each vote"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
