# frozen_string_literal: true

module Decidim
  module Proposals
    # This type represents a ParticipatoryProcess.
    ProposalType = GraphQL::ObjectType.define do
      name "Proposal"
      description "A proposal in a participatory space"

      field(:id, !types.ID)
      field(:title, !types.String)

      field :votes, types.Int do
        resolve ->(proposal, _args, ctx) {
          proposal.proposal_votes_count
        }
      end
    end
  end
end
