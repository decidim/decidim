# frozen_string_literal: true

module Decidim
  module Meetings
    class DataPortabilityRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for data portability
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          meeting_title: resource.meeting.title,
          meeting_description: resource.meeting.description,
          meeting_start_time: resource.meeting.start_time,
          meeting_end_time: resource.meeting.end_time,
          meeting_address: resource.meeting.address,
          meeting_location: resource.meeting.location,
          meeting_location_hints: resource.meeting.location_hints,
          meeting_reference: resource.meeting.reference,
          meeting_attendees_count: resource.meeting.attendees_count,
          meeting_attending_organizations: resource.meeting.attending_organizations,
          meeting_closed_at: resource.meeting.closed_at,
          meeting_closing_report: resource.meeting.closing_report
        }
      end
    end
  end
end
