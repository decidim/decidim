# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::ScopableInterface

      description "A result"

      field :id, ID, "The internal ID for this result", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this result", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this result", null: true
      field :reference, String, "The reference for this result", null: true
      field :start_date, Decidim::Core::DateType, "The start date for this result", null: true
      field :end_date, Decidim::Core::DateType, "The end date for this result", null: true
      field :progress, Float, "The progress for this result", null: true
      field :created_at, Decidim::Core::DateTimeType, "When this result was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this result was updated", null: true
      field :children_count, Integer, "The number of children results", null: true
      field :weight, Integer, "The order of this result", null: false
      field :external_id, String, "The external ID for this result", null: true

      field :children, [Decidim::Accountability::ResultType, null: true], "The childrens results", null: true
      field :parent, Decidim::Accountability::ResultType, "The parent result", null: true
      field :status, Decidim::Accountability::StatusType, "The status for this result", null: true
      field :timeline_entries, [Decidim::Accountability::TimelineEntryType, null: true], "The timeline entries for this result", null: true
    end
  end
end
