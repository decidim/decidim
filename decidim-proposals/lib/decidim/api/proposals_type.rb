# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalsType < Decidim::Core::ComponentType
      graphql_name "Proposals"
      description "A proposals component of a participatory space."

      field :proposal, type: Decidim::Proposals::ProposalType, description: "Finds one proposal", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the proposal", required: true
      end
      field :proposals, type: Decidim::Proposals::ProposalType.connection_type, description: "List all proposals", connection: true, null: true do
        argument :filter, Decidim::Proposals::ProposalInputFilter, "Provides several methods to filter the results", required: false
        argument :order, Decidim::Proposals::ProposalInputSort, "Provides several methods to order the results", required: false
      end

      def proposals(filter: {}, order: {})
        Decidim::Proposals::ProposalListHelper.new(model_class: Proposal).call(object, { filter:, order: }, context)
      end

      def proposal(id:)
        Decidim::Proposals::ProposalFinderHelper.new(model_class: Proposal).call(object, { id: }, context)
      end
    end
  end
end
