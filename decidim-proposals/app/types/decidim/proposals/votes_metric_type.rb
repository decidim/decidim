# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::VotesMetricInterface }]

      name "votesMetric"
      description "A votes related to proposals of a participatory space."

      field :count, !types.Int, "Total votes" do
        resolve ->(organization, _args, _ctx) {
          VotesMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[VotesMetricObjectType], "Data for each vote" do
        resolve ->(organization, _args, _ctx) {
          VotesMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module VotesMetricTypeHelper
      include Decidim::Proposals::BaseProposalMetricTypeHelper

      def self.base_scope(organization)
        proposals = super(organization).except_withdrawn
        ProposalVote.joins(:proposal).where(proposal: proposals)
      end
    end
  end
end
