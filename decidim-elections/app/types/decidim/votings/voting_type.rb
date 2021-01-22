# frozen_string_literal: true

module Decidim
  module Votings
    # This type represents a voting space.
    class VotingType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface

      description "A voting space"

      field :slug, String, null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this voting space.", null: true
      field :start_time, Decidim::Core::DateTimeType, "The start time for this voting space.", null: false
      field :end_time, Decidim::Core::DateTimeType, "The end time for this voting space", null: false
      field :created_at, Decidim::Core::DateTimeType, "The time this voting was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this voting was updated", null: false
    end
  end
end
