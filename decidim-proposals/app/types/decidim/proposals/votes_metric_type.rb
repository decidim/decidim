# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "votesMetric"
      description "A votes related to proposals of a participatory space."
    end

    module VotesMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Decidim::Proposals::Metrics::VotesMetricCount.for(organization, counter_type: type)
      end
    end
  end
end
