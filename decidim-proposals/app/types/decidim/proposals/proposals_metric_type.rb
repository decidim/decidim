# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "ProposalsMetricType"
      description "A proposals component of a participatory space."
    end
  end
end
