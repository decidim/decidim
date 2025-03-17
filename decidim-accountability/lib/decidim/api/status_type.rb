# frozen_string_literal: true

module Decidim
  module Accountability
    class StatusType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TraceableInterface

      description "A status"

      field :description, Decidim::Core::TranslatedFieldType, "The description for this status", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this status", null: false
      field :key, GraphQL::Types::String, "The key for this status", null: true
      field :name, Decidim::Core::TranslatedFieldType, "The name for this status", null: true
      field :progress, GraphQL::Types::Int, "The progress for this status", null: true
      field :results, [Decidim::Accountability::ResultType, { null: true }], "The results for this status", null: true
    end
  end
end
