# frozen_string_literal: true

module Decidim
  module Accountability
    class StatusType < Decidim::Api::Types::BaseObject
      description "A status"

      field :id, ID, "The internal ID for this status", null: false
      field :key, String, "The key for this status", null: true
      field :name, Decidim::Core::TranslatedFieldType, "The name for this status", null: true
      field :created_at, Decidim::Core::DateType, "When this status was created", null: true
      field :updated_at, Decidim::Core::DateType, "When this status was updated", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this status", null: true
      field :progress, Integer, "The progress for this status", null: true

      field :results, [Decidim::Accountability::ResultType, null: true], "The results for this status", null: true
    end
  end
end
