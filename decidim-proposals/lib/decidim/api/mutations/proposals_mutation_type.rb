# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalsMutationType < Decidim::Api::Types::BaseObject
      description "A proposals of a component."

      field :proposal, type: Decidim::Proposals::ProposalMutationType, description: "Mutates a proposal", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the proposal", required: true
      end

      def proposal(id:)
        collection.find(id)
      end

      private

      def collection
        Proposal.where(component: object).not_hidden.published
      end
    end
  end
end
