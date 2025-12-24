# frozen_string_literal: true

module Decidim
  module Meetings
    class UpdateMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "UpdateMeeting"

      description "Updates a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, MeetingAttributes, description: "Input attributes for updating a meeting", required: true
      argument :locale, GraphQL::Types::String, "The locale for which to set the meeting texts", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        params = extract_from(attributes)

        form = form(Decidim::Meetings::MeetingForm).from_params(params)

        UpdateMeeting.call(form, object) do
          on(:ok) do |meeting|
            return meeting.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:update, :meeting, object, context)

        true
      end

      private

      def extract_from(attributes)
        attributes = attributes.to_h.compact

        {
          title: attributes.fetch(:title, translated_attribute(object.title)),
          description: attributes.fetch(:description, translated_attribute(object.description)),
          location: attributes.fetch(:location, translated_attribute(object.location)),
          registration_terms: attributes.fetch(:registration_terms, translated_attribute(object.registration_terms)),
          location_hints: attributes.fetch(:location_hints, translated_attribute(object.location_hints)),
          start_time: attributes.fetch(:start_time, object.start_time),
          end_time: attributes.fetch(:end_time, object.end_time),
          address: attributes.fetch(:address, object.address),
          latitude: attributes.fetch(:latitude, object.latitude),
          longitude: attributes.fetch(:longitude, object.longitude),
          registration_type: attributes.fetch(:registration_type, object.registration_type),
          available_slots: attributes.fetch(:available_slots, object.available_slots),
          type_of_meeting: attributes.fetch(:type_of_meeting, object.type_of_meeting),
          iframe_embed_type: attributes.fetch(:iframe_embed_type, object.iframe_embed_type),
          iframe_access_level: attributes.fetch(:iframe_access_level, object.iframe_access_level),
          online_meeting_url: attributes.fetch(:online_meeting_url, object.online_meeting_url),
          registrations_enabled: attributes.fetch(:registrations_enabled, object.registrations_enabled),
          registration_url: attributes.fetch(:registration_url, object.registration_url)
        }
      end
    end
  end
end
