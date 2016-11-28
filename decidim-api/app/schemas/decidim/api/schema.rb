# frozen_string_literal: true
module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    Schema = GraphQL::Schema.define do
      query QueryType

      orphan_types [ComponentType] +
                   Decidim.component_manifests.map(&:graphql_type).compact

      resolve_type -> (obj, _ctx) {
        if obj.is_a?(Decidim::Component)
          obj.manifest.graphql_type || ComponentType
        end
      }
    end
  end
end
