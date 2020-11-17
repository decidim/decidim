# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultType < GraphQL::Schema::Object
      graphql_name "Result"
      implements Decidim::Core::ComponentInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TimestampsInterface

      description "A result"

      field :id, ID, null: false, description: "The internal ID for this result"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The title for this result"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for this result"
      field :reference, String, null: true, description: "The reference for this result"
      field :startDate, Decidim::Core::DateType, null: true, description: "The start date for this result" do
        def resolve(object:, _args:, context:)
          object.start_date
        end
      end
      field :endDate, Decidim::Core::DateType, null: true, description: "The end date for this result" do
        def resolve(object:, _args:, context:)
          object.end_date
        end
      end
      field :progress, Float, null: true, description: "The progress for this result"
      field :childrenCount, Int, null: true, description: "The number of children results" do
        def resolve(object:, _args:, context:)
          object.children_count
        end
      end
      field :weight, Int, null: false, description: "The order of this result"
      field :externalId, String, null: true, description: "The external ID for this result" do
        def resolve(object:, _args:, context:)
          object.external_id
        end
      end

      field :children, [Decidim::Accountability::ResultType], null: true, description: "The childrens results"
      field :parent, Decidim::Accountability::ResultType, null: true, description: "The parent result"
      field :status, Decidim::Accountability::StatusType, null: true, description: "The status for this result"
      field :timelineEntries, [Decidim::Accountability::TimelineEntryType], null: true, description: "The timeline entries for this result" do
        def resolve(object:, _args:, context:)
          object.timeline_entries
        end
      end
    end
  end
end
