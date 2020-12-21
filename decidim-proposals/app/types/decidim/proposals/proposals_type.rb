# frozen_string_literal: true

module Decidim
  module Proposals

    class ProposalListHelper < Decidim::Core::ComponentListBase
      # only querying published posts
      def query_scope
        super.published
      end
    end

    class ProposalFinderHelper < Decidim::Core::ComponentFinderBase

      # only querying published posts
      def query_scope
        super.published
      end
    end

    class ProposalsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Proposals"
      description "A proposals component of a participatory space."

      field :proposals, type: ProposalType.connection_type, description: "List all proposals", connection: true, null: true do
        argument :order, ProposalInputSort, "Provides several methods to order the results", required: false
        argument :filter, ProposalInputFilter, "Provides several methods to filter the results", required: false
      end

      field :proposal, type: ProposalType, description: "Finds one proposal", null: true  do
        argument :id, ID, "The ID of the proposal", required: true
      end

      def proposals(filter: {}, order: {})
        ProposalListHelper.new(model_class: Proposal).call(object, { filter: filter, order: order}, context)
      end

      def proposal(id: )
        ProposalFinderHelper.new(model_class: Proposal).call(object, {id: id}, context)
      end
    end

  end
end
