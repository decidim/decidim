# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    class CoordinatesType < GraphQL::Schema::Object
      graphql_name  "Coordinates"
      description "Physical coordinates for a location"

      field :latitude, Float, null: false, description: "Latitude of this coordinate"
      field :longitude,Float, null: false, description: "Longitude of this coordinate"

      def latitude
        object[0]
      end

      def longitude
        object[1]
      end
    end
  end
end
