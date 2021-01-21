# frozen_string_literal: true

module Decidim
  module Accountability
    class StatusType < Decidim::Api::Types::BaseObject
      description "A status"

      field :id, GraphQL::Types::ID, "The internal ID for this status", null: false
      field :key, GraphQL::Types::String, "The key for this status", null: true
      field :name, Decidim::Core::TranslatedFieldType, "The name for this status", null: true
      field :created_at, Decidim::Core::DateType, "When this status was created", null: true
      field :updated_at, Decidim::Core::DateType, "When this status was updated", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this status", null: true
      field :progress, GraphQL::Types::Int, "The progress for this status", null: true

      field :results, [Decidim::Accountability::ResultType, { null: true }], "The results for this status", null: true
    end
  end
end
