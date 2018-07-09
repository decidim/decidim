# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::AcceptedProposalsMetricInterface }]

      name "AcceptedProposalsMetricType"
      description "A proposals component of a participatory space."
    end

    module AcceptedProposalsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("accepted_proposals_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Proposals::Metrics::AcceptedProposalsMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
