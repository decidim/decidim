# frozen_string_literal: true

module Decidim
  module Conferences
    class DownloadYourDataConferenceRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for download your data
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
          },
          conference: {
            title: resource.conference.title,
            reference: resource.conference.reference,
            slogan: resource.conference.slogan,
            description: resource.conference.description,
            start_date: resource.conference.start_date,
            end_date: resource.conference.end_date,
            location: resource.conference.location,
            objectives: resource.conference.objectives
          }
        }
      end
    end
  end
end
