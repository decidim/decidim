# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    class Schema < GraphQL::Schema
      mutation(MutationType)
      query(QueryType)

      introspection(DecidimIntrospection)
      query_analyzer RecursionAnalyzer
      query_analyzer AliasAnalyzer

      default_max_page_size Decidim::Api.schema_max_per_page
      max_depth Decidim::Api.schema_max_depth
      max_complexity Decidim::Api.schema_max_complexity

      query_analyzer AliasAnalyzer

      orphan_types(Api.orphan_types)
    end
  end
end
