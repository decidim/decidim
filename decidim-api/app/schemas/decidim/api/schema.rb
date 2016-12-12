# frozen_string_literal: true
module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    Schema = GraphQL::Schema.define do
      query QueryType
      mutation MutationType
    end
  end
end
