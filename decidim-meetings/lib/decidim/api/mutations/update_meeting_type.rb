# frozen_string_literal: true

module Decidim
  module Meetings
    class UpdateMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "UpdateMeeting"

      description "Updates a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, UpdateMeetingAttributes, description: "Input attributes for updating a meeting", required: true

      def resolve(attributes:)
        params = attributes.to_h.compact
        
        # Merge with existing meeting attributes to handle partial updates
        form_params = {
          title: params[:title] || object.title,
          description: params[:description] || object.description,
          location: params[:location] || object.location,
          location_hints: params[:location_hints] || object.location_hints,
          start_time: params[:start_time] || object.start_time,
          end_time: params[:end_time] || object.end_time,
          address: params[:address] || object.address,
          latitude: params[:latitude] || object.latitude,
          longitude: params[:longitude] || object.longitude,
          registration_type: params[:registration_type] || object.registration_type,
          registration_url: params[:registration_url] || object.registration_url,
          available_slots: params.key?(:available_slots) ? params[:available_slots] : object.available_slots,
          registration_terms: params[:registration_terms] || object.registration_terms,
          registrations_enabled: params.key?(:registrations_enabled) ? params[:registrations_enabled] : object.registrations_enabled,
          type_of_meeting: params[:type_of_meeting] || object.type_of_meeting,
          online_meeting_url: params[:online_meeting_url] || object.online_meeting_url,
          iframe_embed_type: params[:iframe_embed_type] || object.iframe_embed_type,
          iframe_access_level: params[:iframe_access_level] || object.iframe_access_level
        }

        form = Decidim::Meetings::MeetingForm.from_params(
          form_params
        ).with_context(
          current_component: object.component,
          current_user:,
          current_organization: current_user.organization
        )

        UpdateMeeting.call(form, object) do
          on(:ok) do |meeting|
            return meeting
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.meetings.update.invalid")
          )
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:update, :meeting, meeting: object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
