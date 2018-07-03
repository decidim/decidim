# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { ProposalsMetricObjectInterface }]

      name "ProposalsMetricObject"
      description "ProposalsMetric object data"
    end
  end
end
