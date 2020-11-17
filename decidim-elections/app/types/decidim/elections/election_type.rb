# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an Election.
    class ElectionType < GraphQL::Schema::Object
      graphql_name "Election"
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      description "An election"

      field :id, ID, null: false, description: "The internal ID of this election"
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title for this election"
      field :description, Decidim::Core::TranslatedFieldType, null: false, description: "The description for this election"
      field :startTime, Decidim::Core::DateTimeType, null: false, description: "The start time for this election" do
        def resolve(object:, _args:, context:)
          object.start_time
        end
      end
      field :endTime, Decidim::Core::DateTimeType, null: false, description: "The end time for this election" do
        def resolve(object:, _args:, context:)
          object.end_time
        end
      end
      field :publishedAt, Decidim::Core::DateTimeType, null: true, description: "When this election was published" do
        def resolve(object:, _args:, context:)
          object.published_at
        end
      end

      field :questions, [Decidim::Elections::ElectionQuestionType], null: false, description: "The questions for this election"
      field :trustees, [Decidim::Elections::TrusteeType], null: false, description: "The trustees for this election"
    end
  end
end
