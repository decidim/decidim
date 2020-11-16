# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an Election.
    ElectionType = GraphQL::ObjectType.define do
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      name "Election"
      description "An election"

      field :id, !types.ID, "The internal ID of this election"
      field :title, !Decidim::Core::TranslatedFieldType, "The title for this election"
      field :description, !Decidim::Core::TranslatedFieldType, "The description for this election"
      field :startTime, !Decidim::Core::DateTimeType, "The start time for this election", property: :start_time
      field :endTime, !Decidim::Core::DateTimeType, "The end time for this election", property: :end_time
      field :publishedAt, Decidim::Core::DateTimeType, "When this election was published", property: :published_at

      field :questions, !types[Decidim::Elections::ElectionQuestionType], "The questions for this election"
      field :trustees, !types[Decidim::Elections::TrusteeType], "The trustees for this election"
    end
  end
end
