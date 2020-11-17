# frozen_string_literal: true

module Decidim
  module Accountability
    class StatusType < GraphQL::Schema::Object
      graphql_name "Status"
      description "A status"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "The internal ID for this status"
      field :key, String, null: true, description: "The key for this status"
      field :name, Decidim::Core::TranslatedFieldType, null: true, description: "The name for this status"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for this status"
      field :progress, Int, null: true, description: "The progress for this status"

      field :results, [Decidim::Accountability::ResultType], null: true, description: "The results for this status"
    end
  end
end
