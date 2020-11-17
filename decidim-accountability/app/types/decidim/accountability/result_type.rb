# frozen_string_literal: true

module Decidim
  module Accountability
    ResultType = GraphQL::ObjectType.define do
      implements Decidim::Core::ComponentInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TimestampsInterface

      name "Result"
      description "A result"

      field :id, !types.ID, "The internal ID for this result"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this result"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this result"
      field :reference, types.String, "The reference for this result"
      field :startDate, Decidim::Core::DateType, "The start date for this result", property: :start_date
      field :endDate, Decidim::Core::DateType, "The end date for this result", property: :end_date
      field :progress, types.Float, "The progress for this result"
      field :childrenCount, types.Int, "The number of children results", property: :children_count
      field :weight, !types.Int, "The order of this result"
      field :externalId, types.String, "The external ID for this result", property: :external_id

      field :children, types[Decidim::Accountability::ResultType], "The childrens results"
      field :parent, Decidim::Accountability::ResultType, "The parent result"
      field :status, Decidim::Accountability::StatusType, "The status for this result"
      field :timelineEntries, types[Decidim::Accountability::TimelineEntryType], "The timeline entries for this result", property: :timeline_entries
    end
  end
end
