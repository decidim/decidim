# frozen_string_literal: true

module Decidim
  module Meetings
    class SchemaOrgEventMeetingSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper
      include ActionView::Helpers::UrlHelper

      # Public: Initializes the serializer with a meeting.
      def initialize(meeting)
        @meeting = meeting
      end

      # Serializes a meeting for the Schema.org Event type
      #
      # @see https://schema.org/Event
      # @see https://developers.google.com/search/docs/appearance/structured-data/event?hl=en
      def serialize
        attributes = {
          "@context": "https://schema.org",
          "@type": "Event",
          name: decidim_escape_translated(meeting.title),
          description: decidim_escape_translated(meeting.description),
          startDate: meeting.start_time.iso8601,
          endDate: meeting.end_time.iso8601,
          organizer:,
          eventAttendanceMode: event_attendance_mode,
          eventStatus: "https://schema.org/EventScheduled",
          location:
        }

        attributes = attributes.merge(image:) if meeting.photos.any?
        attributes
      end

      private

      attr_reader :meeting
      alias resource meeting

      def organizer
        case meeting.author.class.name
        when "Decidim::Organization"
          organizer_organization
        when "Decidim::User"
          organizer_user
        end
      end

      def organizer_organization
        {
          "@type": "Organization",
          name: decidim_escape_translated(meeting.author.name),
          url: EngineRouter.new("decidim", router_options).root_url
        }
      end

      def organizer_user
        {
          "@type": "Person",
          name: decidim_escape_translated(meeting.author.name),
          url: profile_url(meeting.author)
        }
      end

      def router_options = { host: meeting.organization.host }

      def event_attendance_mode
        case meeting.type_of_meeting
        when "online"
          "https://schema.org/OnlineEventAttendanceMode"
        when "hybrid"
          "https://schema.org/MixedEventAttendanceMode"
        else
          "https://schema.org/OfflineEventAttendanceMode"
        end
      end

      def location
        case meeting.type_of_meeting
        when "online"
          location_virtual
        when "hybrid"
          [location_postal_address, location_virtual]
        else
          location_postal_address
        end
      end

      def location_postal_address
        address = {
          "@type": "PostalAddress",
          streetAddress: decidim_escape_translated(meeting.address)
        }

        address = address.merge({ addressLocality: geocoder_city }) if geocoder_city.present?
        address = address.merge({ addressRegion: geocoder_state }) if geocoder_state.present?
        address = address.merge({ postalCode: geocoder_postal_code }) if geocoder_postal_code.present?
        address = address.merge({ addressCountry: geocoder_country }) if geocoder_country.present?

        {
          "@type": "Place",
          name: decidim_escape_translated(meeting.location),
          address:
        }
      end

      def location_virtual
        {
          "@type": "VirtualLocation",
          url: meeting.online_meeting_url
        }
      end

      def geocoder
        return if meeting.latitude.blank? || meeting.longitude.blank?

        @geocoder ||= Geocoder.search([meeting.latitude, meeting.longitude]).first
      end

      def geocoder_city
        @geocoder_city ||= geocoder&.city
      end

      def geocoder_state
        @geocoder_state ||= geocoder&.state
      end

      def geocoder_postal_code
        @geocoder_postal_code ||= geocoder&.postal_code
      end

      def geocoder_country
        @geocoder_country ||= geocoder&.country
      end

      def image = meeting.photos.map(&:thumbnail_url)
    end
  end
end
