# frozen_string_literal: true

module Decidim
  module Conferences
    class DataPortabilityConferenceInviteSerializer < Decidim::Exporters::Serializer
      # Serializes a conference invite for data portability
      def serialize
        {
          id: resource.id,
          sent_at: resource.sent_at,
          accepted_at: resource.accepted_at,
          rejected_at: resource.rejected_at,
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
