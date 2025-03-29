# frozen_string_literal: true

module Decidim
  module Accountability
    class TimelineEntryType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TraceableInterface

      description "A Timeline Entry"

      field :description, Decidim::Core::TranslatedFieldType, "The description for this timeline entry", null: true
      field :entry_date, Decidim::Core::DateType, "The entry date for this timeline entry", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this timeline entry", null: false
      field :result, Decidim::Accountability::ResultType, "The result for this timeline entry", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this timeline entry", null: true
    end
  end
end
