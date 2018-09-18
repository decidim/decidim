# frozen_string_literal: true

module Decidim
  module Conferences
    class DataPortabilityConferenceRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for data portability
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
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
