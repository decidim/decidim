# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::VotesMetricInterface }]

      name "votesMetric"
      description "A votes related to proposals of a participatory space."
    end

    module VotesMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("votes_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Proposals::Metrics::VotesMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
