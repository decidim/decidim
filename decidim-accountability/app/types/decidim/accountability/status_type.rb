# frozen_string_literal: true

module Decidim
  module Accountability
    StatusType = GraphQL::ObjectType.define do
      name "Status"
      description "A status"

      field :id, !types.ID, "The internal ID for this status"
      field :key, types.String, "The key for this status"
      field :name, Decidim::Core::TranslatedFieldType, "The name for this status"
      field :createdAt, Decidim::Core::DateType, "When this status was created", property: :created_at
      field :updatedAt, Decidim::Core::DateType, "When this status was updated", property: :updated_at
      field :description, Decidim::Core::TranslatedFieldType, "The description for this status"
      field :progress, types.Int, "The progress for this status"

      field :results, types[Decidim::Accountability::ResultType], "The results for this status"
    end
  end
end
