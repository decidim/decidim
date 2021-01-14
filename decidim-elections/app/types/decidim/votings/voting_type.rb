# frozen_string_literal: true

module Decidim
  module Votings
    # This type represents a voting space.
    VotingType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface },
        -> { Decidim::Core::TraceableInterface }
      ]

      name "Voting"
      description "A voting space"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this voting"
      field :slug, !types.String, "Slug of this voting"
      field :createdAt, Decidim::Core::DateTimeType, "When this voting was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "When this voting was updated", property: :updated_at
      field :startTime, !Decidim::Core::DateTimeType, "The start time for this voting", property: :start_time
      field :endTime, !Decidim::Core::DateTimeType, "The end time for this voting", property: :end_time
    end
  end
end
