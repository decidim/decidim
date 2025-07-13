# frozen_string_literal: true

module Decidim
  module Conferences
    class DownloadYourDataConferenceRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for download your data
      def serialize
        {
          id: resource.id,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          confirmed_at: resource.confirmed_at,
          registration_type: {
            title: resource.registration_type.title,
            price: resource.registration_type.price
          },
          conference: {
            url: Decidim::EngineRouter.main_proxy(resource.conference).conference_url(resource.conference),
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
