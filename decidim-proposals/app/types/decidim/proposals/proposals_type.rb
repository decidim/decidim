# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Proposals"
      description "A proposals component of a participatory space."

      connection :proposals,
                 type: ProposalType.connection_type,
                 description: "List all proposals",
                 function: ProposalListHelper.new(model_class: Proposal)

      field :proposal,
            type: ProposalType,
            description: "Finds one proposal",
            function: ProposalFinderHelper.new(model_class: Proposal)
    end

    class ProposalListHelper < Decidim::Core::ComponentListBase
      argument :order, ProposalInputSort, "Provides several methods to order the results"
      argument :filter, ProposalInputFilter, "Provides several methods to filter the results"
    end

    class ProposalFinderHelper < Decidim::Core::ComponentFinderBase
      argument :id, !types.ID, "The ID of the proposal"
    end
  end
end
