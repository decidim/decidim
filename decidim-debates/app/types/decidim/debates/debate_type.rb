# frozen_string_literal: true

module Decidim
  module Debates
    class DebateType < GraphQL::Schema::Object
      graphql_name "Debate"
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TimestampsInterface

      description "A debate"

      field :id, ID, null: false, description: "The internal ID for this debate"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The title for this debate"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for this debate"
      field :instructions, Decidim::Core::TranslatedFieldType, null: true, description: "The instructions for this debate"
      field :startTime, Decidim::Core::DateTimeType, null: true, description: "The start time for this debate" do
        def resolve(object:, _args:, context:)
          object.start_time
        end
      end
      field :endTime, Decidim::Core::DateTimeType, null: true, description: "The end time for this debate" do
        def resolve(object:, _args:, context:)
          object.end_time
        end
      end
      field :image, String, null: true, description: "The image of this debate"
      field :informationUpdates, Decidim::Core::TranslatedFieldType, null: true, description: "The information updates for this debate" do
        def resolve(object:, _args:, context:)
          object.information_updates
        end
      end
      field :reference, String, null: true, description: "The reference for this debate"
    end
  end
end
