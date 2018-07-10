# frozen_string_literal: true

module Decidim
  module Meetings
    class DataPortabilityRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for data portability
      def serialize
        {
          id: resource.id,
          code: resource.code,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          meeting: {
            title: resource.meeting.title,
            description: resource.meeting.description,
            start_time: resource.meeting.start_time,
            end_time: resource.meeting.end_time,
            address: resource.meeting.address,
            location: resource.meeting.location,
            location_hints: resource.meeting.location_hints,
            reference: resource.meeting.reference,
            attendees_count: resource.meeting.attendees_count,
            attending_organizations: resource.meeting.attending_organizations,
            closed_at: resource.meeting.closed_at,
            closing_report: resource.meeting.closing_report
          }
        }
      end
    end
  end
end
