# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    class Schema < GraphQL::Schema
      mutation(MutationType)
      query(QueryType)

      default_max_page_size 50
      max_depth 15
      max_complexity 300

      orphan_types(Api.orphan_types)
    end
  end
end
