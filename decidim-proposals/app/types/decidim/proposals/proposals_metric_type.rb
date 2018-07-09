# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::ProposalsMetricInterface }]

      name "ProposalsMetricType"
      description "A proposals component of a participatory space."
    end

    module ProposalsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("proposals_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Proposals::Metrics::ProposalsMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
