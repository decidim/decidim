# frozen_string_literal: true

module Decidim
  module Meetings
    class BaseDownloadYourDataSerializer < Decidim::Exporters::Serializer
      # This is the Base class for Invite and Registrations models for the download your data feature
      def serialize
        {
          id: resource.id,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          meeting: {
            title: resource.meeting.title,
            url: Decidim::ResourceLocatorPresenter.new(resource.meeting).url,
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
