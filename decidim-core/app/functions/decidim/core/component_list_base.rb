# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for listing components
    # Used in the keyword that lists some type of a specific component.
    # For instance, "proposals" if it is a Proposal:
    #
    # participatoryProcesses {
    #   components {
    #   ... on Proposals {
    #        proposals(...)
    #     }
    #   }
    # }
    #
    # Needs to be extended and add arguments
    # Usually something like:
    #
    #   class ProposalListHelper < Decidim::Core::ComponentListBase
    #     argument :order, ProposalInputSort, "Provides several methods to order the results"
    #     argument :filter, ProposalInputFilter, "Provides several methods to filter the results"
    #   end
    #
    # For an example check
    # decidim-proposals/app/types/decidim/proposals/proposals_type.rb
    #
    class ComponentListBase < GraphQL::Function
      include NeedsApiFilterAndOrder
      attr_reader :model_class

      def initialize(model_class:)
        @model_class = model_class
      end

      def call(component, args, _ctx)
        @query = model_class.where(component: component)
                            .published
                            .includes(:component)

        add_filter_keys(args[:filter])
        order = filter_keys_by_settings(args[:order].to_h, component)
        add_order_keys(order)
        @query
      end

      private

      def filter_keys_by_settings(kwargs, component)
        kwargs.select do |key, _value|
          case key
          when :vote_count
            !component.current_settings.votes_hidden?
          else
            true
          end
        end
      end
    end
  end
end
