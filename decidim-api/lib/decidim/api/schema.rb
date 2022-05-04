# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    class Schema < GraphQL::Schema
      mutation(MutationType)
      query(QueryType)

      default_max_page_size Decidim::Api.schema_max_per_page
      max_depth Decidim::Api.schema_max_depth
      max_complexity Decidim::Api.schema_max_complexity

      orphan_types(Api.orphan_types)
    end
  end
end
