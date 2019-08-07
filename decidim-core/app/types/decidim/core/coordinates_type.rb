# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    CoordinatesType = GraphQL::ObjectType.define do
      name "Coordinates"
      description "Physical coordinates for a location"

      field :latitude, !types.Float, "Latitude of this coordinate" do
        resolve ->(coordinates, _args, _ctx) { coordinates[0] }
      end

      field :longitude, !types.Float, "Longitude of this coordinate" do
        resolve ->(coordinates, _args, _ctx) { coordinates[1] }
      end
    end
  end
end
