# frozen_string_literal: true

module Decidim
  module Core
    # A resolver for the GraphQL endpoint components insidea a participatory_space
    class BareComponentList < GraphQL::Function
      include NeedsFilterAndOrder
      attr_reader :model_class

      def initialize
        @model_class = Component
      end

      def call(participatory_space, args, _ctx)
        @query = Decidim::Component
        # remove default ordering if custom order required
        @query = @query.unscoped if args[:order]
        @query = @query.where(
          participatory_space: participatory_space
        ).published
        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        @query
      end
    end
  end
end
