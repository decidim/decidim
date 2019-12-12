# frozen_string_literal: true

module Decidim
  module Debates
    DebateType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::CategorizableInterface },
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::AuthorableInterface }
      ]

      name "Debate"
      description "A debate"

      field :id, !types.ID, "The internal ID for this debate"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this debate"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this debate"
      field :instructions, Decidim::Core::TranslatedFieldType, "The instructions for this debate"
      field :startTime, Decidim::Core::DateTimeType, "The start time for this debate", property: :start_time
      field :endTime, Decidim::Core::DateTimeType, "The end time for this debate", property: :end_time
      field :image, types.String, "The image of this debate"
      field :createdAt, Decidim::Core::DateTimeType, "When this debate was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "When this debate was updated", property: :updated_at
      field :informationUpdates, Decidim::Core::TranslatedFieldType, "The information updates for this debate", property: :information_updates
      field :reference, types.String, "The reference for this debate"
    end
  end
end
