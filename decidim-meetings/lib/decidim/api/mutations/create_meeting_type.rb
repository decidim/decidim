# frozen_string_literal: true

module Decidim
  module Meetings
    class CreateMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateMeeting"

      description "Creates a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, MeetingAttributes, description: "Input attributes for creating a meeting", required: true
      argument :locale, GraphQL::Types::String, "The locale for which to set the meeting texts", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        params = attributes.to_h.slice(
          :address,
          :available_slots,
          :description,
          :end_time,
          :iframe_access_level,
          :iframe_embed_type,
          :latitude,
          :location,
          :location_hints,
          :longitude,
          :online_meeting_url,
          :registration_terms,
          :registration_type,
          :registration_url,
          :registrations_enabled,
          :start_time,
          :taxonomies,
          :title,
          :type_of_meeting
        )

        params[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: params[:taxonomies]).pluck(:id) if params[:taxonomies]

        form = form(Decidim::Meetings::MeetingForm).from_params(params)

        Decidim::Meetings::CreateMeeting.call(form) do
          on(:ok) do |meeting|
            return meeting.reload
          end
          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        unless super && allowed_to?(:create, :meeting, Meeting.new(component: current_component), { current_user:, current_component: })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end
    end
  end
end
