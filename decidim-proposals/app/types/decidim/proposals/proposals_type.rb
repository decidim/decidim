# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalsType < GraphQL::Schema::Object
      graphql_name "Proposals"
      implements Decidim::Core::ComponentInterface
      description "A proposals component of a participatory space."

      field :proposals, ProposalType.connection_type, null: false, description: "List all proposals" do
        def resolve(object:, _args:, context:)
          Decidim::Proposals::ProposalListHelper.new(model_class: Proposal).call(object, _args, context)
        end
      end

      field(:proposal, ProposalType, null: true, description: "Finds one proposal") do
        argument :id, ID, required: true
        def resolve(object:, _args:, context:)
          Decidim::Proposals::ProposalFinderHelper.new(model_class: Proposal).call(object, _args, context)
        end
      end
    end

    class ProposalListHelper < Decidim::Core::ComponentListBase
      argument :order, ProposalInputSort,  description: "Provides several methods to order the results"
      argument :filter, ProposalInputFilter, description: "Provides several methods to filter the results"

      # only querying published posts
      def query_scope
        super.published
      end
    end

    class ProposalFinderHelper < Decidim::Core::ComponentFinderBase
      argument :id, GraphQL::Types::ID,  description: "The ID of the proposal"

      # only querying published posts
      def query_scope
        super.published
      end
    end
  end
end
