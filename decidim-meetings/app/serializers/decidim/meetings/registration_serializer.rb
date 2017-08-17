# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          }
        }
      end
    end
  end
end
