# frozen_string_literal: true

module Decidim
  module Accountability
    StatusType = GraphQL::ObjectType.define do
      name "Status"
      description "A status"
      implements Decidim::Core::TimestampsInterface


      field :id, !types.ID, "The internal ID for this status"
      field :key, types.String, "The key for this status"
      field :name, Decidim::Core::TranslatedFieldType, "The name for this status"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this status"
      field :progress, types.Int, "The progress for this status"

      field :results, types[Decidim::Accountability::ResultType], "The results for this status"
    end
  end
end
