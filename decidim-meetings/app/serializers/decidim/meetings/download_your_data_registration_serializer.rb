# frozen_string_literal: true

module Decidim
  module Meetings
    class DownloadYourDataRegistrationSerializer < Decidim::Exporters::Serializer
      # Serializes a registration for download your data
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
            closing_report: resource.meeting.closing_report,
            published_at: resource.meeting.published_at
          }
        }
      end
    end
  end
end
