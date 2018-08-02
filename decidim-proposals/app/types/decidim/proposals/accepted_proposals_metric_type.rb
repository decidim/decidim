# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "AcceptedProposalsMetricType"
      description "A proposals component of a participatory space."
    end
  end
end
