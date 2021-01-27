# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    class CoordinatesType < Decidim::Api::Types::BaseObject
      description "Physical coordinates for a location"

      field :latitude, GraphQL::Types::Float, "Latitude of this coordinate", null: false
      field :longitude, GraphQL::Types::Float, "Longitude of this coordinate", null: false

      def latitude
        object[0]
      end

      def longitude
        object[1]
      end
    end
  end
end
