# frozen_string_literal: true
require "decidim/api/query_type"

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    Schema = GraphQL::Schema.define do
      query QueryType
    end
  end
end
