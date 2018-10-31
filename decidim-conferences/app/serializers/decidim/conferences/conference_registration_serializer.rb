# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a conference registration
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          registration_type: {
            title: resource.registration_type.title,
            price: resource.registration_type.price
          }
        }
      end
    end
  end
end
