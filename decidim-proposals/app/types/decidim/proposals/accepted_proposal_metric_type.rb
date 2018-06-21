# frozen_string_literal: true

module Decidim
  module Proposals
    AcceptedProposalMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Proposals::AcceptedProposalMetricInterface }]

      name "AcceptedProposalMetricType"
      description "A proposals component of a participatory space."
    end

    module AcceptedProposalMetricTypeHelper
      include Decidim::Proposals::BaseProposalMetricTypeHelper

      def self.base_scope(organization)
        super(organization).accepted
      end
    end
  end
end
