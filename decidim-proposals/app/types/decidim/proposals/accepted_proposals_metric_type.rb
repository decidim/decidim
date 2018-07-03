# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::AcceptedProposalsMetricInterface }]

      name "AcceptedProposalsMetricType"
      description "A proposals component of a participatory space."
    end

    module AcceptedProposalsMetricTypeHelper
      include Decidim::Proposals::BaseProposalMetricTypeHelper

      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("accepted_proposals_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          query = super(organization).accepted
          base_metric_scope(query, :published_at, type)
        end
      end
    end
  end
end
