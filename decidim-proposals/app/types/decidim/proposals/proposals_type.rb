# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Proposals"
      description "A proposals component of a participatory space."

      connection :proposals, ProposalType.connection_type do
        resolve ->(feature, _args, _ctx) {
                  ProposalsTypeHelper.base_scope(feature).includes(:feature)
                }
      end

      field(:proposal, ProposalType) do
        argument :id, !types.ID

        resolve ->(feature, args, _ctx) {
          ProposalsTypeHelper.base_scope(feature).find_by(id: args[:id])
        }
      end
    end

    module ProposalsTypeHelper
      def self.base_scope(feature)
        Proposal
          .where(feature: feature)
          .published
      end
    end
  end
end
