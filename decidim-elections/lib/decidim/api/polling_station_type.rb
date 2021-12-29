# frozen_string_literal: true

module Decidim
  module Votings
    # This type represents a polling station.
    class PollingStationType < Decidim::Api::Types::BaseObject
      description "A polling station for a voting"

      field :id, GraphQL::Types::ID, "The internal ID of this polling station", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this polling station", null: true
      field :address, GraphQL::Types::String, "The physical address of this polling station (used for geolocation)", null: true
      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this polling station", null: true
      field :location, Decidim::Core::TranslatedFieldType, "The location of this polling station (free format)", null: true
      field :location_hints, Decidim::Core::TranslatedFieldType, "The location of this polling station (free format)", null: true
      field :created_at, Decidim::Core::DateTimeType, "When this polling station was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this polling station was updated", null: true
      field :voting, Decidim::Votings::VotingType, null: false

      def coordinates
        [object.latitude, object.longitude]
      end
    end
  end
end
