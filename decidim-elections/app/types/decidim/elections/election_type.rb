# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an Election.
    ElectionType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::TraceableInterface }
      ]

      name "Election"
      description "An election"

      field :id, !types.ID, "The internal ID of this election"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this election"
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle for this election"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this election"
      field :startTime, Decidim::Core::DateTimeType, "The start time for this election", property: :start_time
      field :endTime, Decidim::Core::DateTimeType, "The end time for this election", property: :end_time
      field :createdAt, Decidim::Core::DateTimeType, "When this election was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "When this election was updated", property: :updated_at
    end
  end
end
