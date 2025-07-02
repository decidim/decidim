# frozen_string_literal: true

module Decidim
  module Core
    module GeoLocatableInterface
      description "An interface that can be used in geo-locatable objects."
      include Decidim::Api::Types::BaseInterface

      field :address, GraphQL::Types::String, "address of the resource"
      field :latitude, GraphQL::Types::Float, "latitude of the resource"
      field :longitude, GraphQL::Types::Float, "longitude of the resource"
    end
  end
end
