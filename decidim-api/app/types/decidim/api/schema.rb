# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    Schema = GraphQL::Schema.define do
      query QueryType
      mutation MutationType

      default_max_page_size 50
      max_depth 15
      max_complexity 300

      orphan_types(Api.orphan_types)

      resolve_type ->(_type, _obj, _ctx) {}
    end
  end
end
