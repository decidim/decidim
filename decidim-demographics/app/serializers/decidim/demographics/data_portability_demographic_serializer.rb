# frozen_string_literal: true

module Decidim
  module Demographics
    class DataPortabilityDemographicSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for data portability
      def serialize
        object = {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          }
        }
        resource.data.map do |key, value|
          next if value.blank?

          object[key.to_sym] = value
        end
        object
      end
    end
  end
end
