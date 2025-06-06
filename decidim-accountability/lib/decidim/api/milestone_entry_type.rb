# frozen_string_literal: true

module Decidim
  module Accountability
    class MilestoneEntryType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TraceableInterface

      description "A Milestone"

      field :description, Decidim::Core::TranslatedFieldType, "The description for this milestone", null: true
      field :entry_date, Decidim::Core::DateType, "The entry date for this milestone", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this milestone", null: false
      field :result, Decidim::Accountability::ResultType, "The result for this milestone", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this milestone", null: true
    end
  end
end
