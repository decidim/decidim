# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::VotesMetricInterface }]

      name "votesMetric"
      description "A votes related to proposals of a participatory space."
    end

    module VotesMetricTypeHelper
      include Decidim::Proposals::BaseProposalMetricTypeHelper

      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("votes_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          proposals = super(organization).except_withdrawn
          query = ProposalVote.joins(:proposal).where(proposal: proposals)
          base_metric_scope(query, :"decidim_proposals_proposal_votes.created_at", type)
        end
      end
    end
  end
end
