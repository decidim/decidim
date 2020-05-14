# frozen_string_literal: true

module Decidim
  module Core
    # A resolver for the GraphQL users/groups endpoints
    # Used in the keyword "users", ie:
    #
    # users(filter: {nickname: "foo"}) {
    #   name
    # }
    #
    class UserEntityList < GraphQL::Function
      include NeedsApiFilterAndOrder
      argument :order, UserEntityInputSort, "Provides several methods to order the results"
      argument :filter, UserEntityInputFilter, "Provides several methods to filter the results"

      def initialize
        @model_class = Decidim::UserBaseEntity
      end

      def call(_obj, args, ctx)
        @query = Decidim::UserBaseEntity
                 .where(organization: ctx[:current_organization])
                 .where.not(confirmed_at: nil)
        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        @query
      end
    end
  end
end
