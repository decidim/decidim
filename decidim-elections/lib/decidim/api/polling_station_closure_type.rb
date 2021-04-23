# frozen_string_literal: true

module Decidim
  module Votings
    # This type represents a Polling Station closure for an election.
    class PollingStationClosureType < Decidim::Api::Types::BaseObject
      description "A polling station election closure"

      field :id, GraphQL::Types::ID, "The internal ID of this result", null: false
      field :created_at, Decidim::Core::DateTimeType, "When this result was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this result was updated", null: true
      field :election, Decidim::Elections::ElectionType, "The election for this closure", null: false
      field :polling_officer_notes, GraphQL::Types::String, "The polling officer notes for this closure", null: false
      field :results, [Decidim::Elections::ElectionResultType, { null: true }], "The results for this closure", null: false
      field :polling_station, Decidim::Votings::PollingStationType, "The polling station for this closure", null: true
    end
  end
end
