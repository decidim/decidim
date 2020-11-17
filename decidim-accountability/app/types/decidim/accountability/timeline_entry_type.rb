# frozen_string_literal: true

module Decidim
  module Accountability
    class TimelineEntryType < GraphQL::Schema::Object
      graphql_name "TimelineEntry"
      description "A Timeline Entry"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "The internal ID for this timeline entry"
      field :entryDate, Decidim::Core::DateType, null: true, description: "The entry date for this timeline entry" do
        def resolve(object:, _args:, context:)
          object.entry_date
        end
      end
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for this timeline entry"

      field :result, Decidim::Accountability::ResultType, null: true, description: "The result for this timeline entry"
    end
  end
end
