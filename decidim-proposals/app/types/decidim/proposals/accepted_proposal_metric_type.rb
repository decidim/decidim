# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::AcceptedProposalMetricInterface }]

      name "AcceptedProposalMetricType"
      description "A proposals component of a participatory space."

      field :count, !types.Int, "Total accepted proposals" do
        resolve ->(organization, _args, _ctx) {
          AcceptedProposalMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[ProposalMetricObjectType], "Data for each proposal" do
        resolve ->(organization, _args, _ctx) {
          AcceptedProposalMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module AcceptedProposalMetricTypeHelper
      include Decidim::Proposals::BaseProposalMetricTypeHelper

      def self.base_scope(organization)
        super(organization).accepted
      end
    end
  end
end
