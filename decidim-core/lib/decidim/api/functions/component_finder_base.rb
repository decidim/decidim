# frozen_string_literal: true

module Decidim
  module Core
    # An abstract class with the logic for the GraphQL endpoint for a single component to be searchable.
    # Normal components (such as Proposal) can inherit from this class and just
    # add the needed search arguments
    #
    # Usually something like:
    #
    #   class ProposalFinderHelper < Decidim::Core::ComponentFinderBase
    #     argument :id, !types.ID, "The ID of the proposal"
    #   end
    #
    # For an example check
    # decidim-proposals/app/types/decidim/proposals/proposals_type.rb
    class ComponentFinderBase
      attr_reader :model_class

      def initialize(model_class:)
        @model_class = model_class
      end

      def call(component, args, _ctx)
        @query = { component: }
        args.keys.each do |key|
          @query[key] = args[key]
        end
        query_scope.find_by(@query)
      end

      # By default, any model in its defaul scope
      # Particular implementations may restrict this by adding
      # additional constrains
      def query_scope
        model_class
      end
    end
  end
end
