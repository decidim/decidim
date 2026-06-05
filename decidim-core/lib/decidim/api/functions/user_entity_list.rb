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
    class UserEntityList
      include NeedsApiFilterAndOrder
      include NeedsApiDefaultOrder

      def initialize
        @model_class = Decidim::UserBaseEntity
      end

      def call(_obj, args, ctx)
        @query = Decidim::UserBaseEntity
                 .where(organization: ctx[:current_organization])
                 .confirmed
                 .not_blocked
        add_filter_keys(args[:filter])
        add_order_keys(args[:order].to_h)
        add_default_order
        @query
      end
    end
  end
end
