# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "AcceptedProposalsMetricType"
      description "A proposals component of a participatory space."
    end

    module AcceptedProposalsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Decidim::Proposals::Metrics::AcceptedProposalsMetricCount.for(organization, counter_type: type)
      end
    end
  end
end
