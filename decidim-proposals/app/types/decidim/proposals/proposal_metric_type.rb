# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::ProposalMetricInterface }]

      name "ProposalMetricType"
      description "A proposals component of a participatory space."

      field :count, !types.Int, "Total proposals" do
        resolve ->(organization, _args, _ctx) {
          ProposalMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[ProposalMetricObjectType], "Data for each proposal" do
        resolve ->(organization, _args, _ctx) {
          ProposalMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module ProposalMetricTypeHelper
      def self.base_scope(_organization)
        # TODO: add organization scope
        Proposal
          .published.except_withdrawn.not_hidden
      end
    end
  end
end
