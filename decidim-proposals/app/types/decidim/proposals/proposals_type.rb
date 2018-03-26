# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Proposals"
      description "A proposals component of a participatory space."

      connection :proposals, ProposalType.connection_type do
        resolve ->(component, _args, _ctx) {
                  ProposalsTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:proposal, ProposalType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          ProposalsTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module ProposalsTypeHelper
      def self.base_scope(component)
        Proposal
          .where(component: component)
          .published
      end
    end
  end
end
