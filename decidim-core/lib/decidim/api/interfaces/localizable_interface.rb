# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a localizable (that has address, latitude and longitude) object.
    module LocalizableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in localizable objects."

      field :address, GraphQL::Types::String, "The physical address (location) of this result", null: true
      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this result", null: true

      def coordinates
        [object.latitude, object.longitude]
      end
    end
  end
end
