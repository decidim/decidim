# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentCollectionAttributes < Decidim::Api::Types::BaseInputObject
      description "Attributes for attachment collections"

      argument :description, GraphQL::Types::JSON, description: "The attachment collection description", required: false
      argument :key, GraphQL::Types::String, description: "The attachment collection key, i.e. its technical handle", required: false
      argument :name, GraphQL::Types::JSON, description: "The attachment collection name", required: false
      argument :slug, GraphQL::Types::String, description: "DEPRECATED: Use 'key' instead", required: false
      argument :weight, GraphQL::Types::Int, description: "The attachment collection weight", required: false, default_value: 0
    end
  end
end
