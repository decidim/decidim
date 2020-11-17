# frozen_string_literal: true

module Decidim
  module Accountability
    TimelineEntryType = GraphQL::ObjectType.define do
      name "TimelineEntry"
      description "A Timeline Entry"
      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "The internal ID for this timeline entry"
      field :entryDate, Decidim::Core::DateType, "The entry date for this timeline entry", property: :entry_date
      field :description, Decidim::Core::TranslatedFieldType, "The description for this timeline entry"

      field :result, Decidim::Accountability::ResultType, "The result for this timeline entry"
    end
  end
end
