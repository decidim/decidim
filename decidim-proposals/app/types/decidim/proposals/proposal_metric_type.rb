# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::ProposalMetricInterface }]

      name "ProposalMetricType"
      description "A proposals component of a participatory space."
    end

    module ProposalMetricTypeHelper
      include Decidim::Proposals::BaseProposalMetricTypeHelper

      def self.base_scope(organization)
        super(organization).except_withdrawn
      end
    end
  end
end
