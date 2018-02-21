# frozen_string_literal: true

module Decidim
  module Proposals
    # This type represents a ParticipatoryProcess.
    ProposalsType = GraphQL::ObjectType.define do
      interfaces [Decidim::Core::ComponentInterface]

      name "Proposals"
      description "A proposals component of a participatory space."

      connection :proposals, ProposalType.connection_type do
        resolve -> (feature, _args, _ctx) {
                  Proposal.where(
                    feature: feature
                  ).limit(5)
                }
      end

      field(:proposal, ProposalType.connection_type) do
        argument :id, !types.ID

        resolve -> (feature, args, _ctx) {
          Proposal.where(feature: feature).find(args[:id])
        }
      end
    end
  end
end
