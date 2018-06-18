# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalMetricObjectType = GraphQL::ObjectType.define do
      interfaces [
        -> { ProposalMetricObjectInterface },
        -> { Decidim::Core::CategorizableInterface }
      ]

      name "ProposalMetricObject"
      description "ProposalMetric object data"
    end
  end
end
