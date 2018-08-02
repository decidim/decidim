# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "ProposalsMetricType"
      description "A proposals component of a participatory space."
    end

    module ProposalsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Decidim::Proposals::Metrics::ProposalsMetricCount.for(organization, counter_type: type)
      end
    end
  end
end
