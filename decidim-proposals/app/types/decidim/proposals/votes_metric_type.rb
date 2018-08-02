# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "votesMetric"
      description "A votes related to proposals of a participatory space."
    end
  end
end
