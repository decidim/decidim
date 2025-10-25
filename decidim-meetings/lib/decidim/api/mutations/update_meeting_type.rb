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

        # Map the attributes to the form format
        form_params = params.merge(
          current_component: object.component
        )

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
        super && allowed_to?(:update, :meeting, object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
