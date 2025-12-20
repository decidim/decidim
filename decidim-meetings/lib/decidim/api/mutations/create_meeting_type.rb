# frozen_string_literal: true

module Decidim
  module Meetings
    class CreateMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateMeeting"

      description "Creates a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, CreateMeetingAttributes, description: "Input attributes for creating a meeting", required: true
      argument :component_id, GraphQL::Types::ID, description: "The ID of the component where the meeting will be created", required: true

      def resolve(component_id:, attributes:)
        component = current_user.organization.components.find_by(id: component_id)

        unless component
          return GraphQL::ExecutionError.new(
            "Component not found"
          )
        end

        unless component.manifest_name == "meetings"
          return GraphQL::ExecutionError.new(
            "Invalid component type. Must be a meetings component."
          )
        end

        attrs = attributes.to_h

        # Build taxonomizations from taxonomy_ids
        taxonomizations = build_taxonomizations(attrs.delete(:taxonomy_ids), component.organization)

        # Prepare form parameters
        form_params = attrs.merge(
          taxonomizations:,
          registrations_enabled: attrs[:registration_type] == "on_this_platform",
          clean_type_of_meeting: attrs[:type_of_meeting]
        )

        form = Decidim::Meetings::MeetingForm.from_params(
          form_params
        ).with_context(
          current_component: component,
          current_user:,
          current_organization: current_user.organization
        )

        CreateMeeting.call(form) do
          on(:ok) do |meeting|
            return meeting
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.meetings.create.invalid")
          )
        end
      end

      def authorized?(component_id:, attributes:)
        component = current_user.organization.components.find_by(id: component_id)
        return false unless component

        super && allowed_to?(:create, :meeting, {}, { current_component: component })
      end

      def current_user
        context[:current_user]
      end

      private

      def build_taxonomizations(taxonomy_ids, organization)
        return [] unless taxonomy_ids.present?

        taxonomy_ids.map do |id|
          taxonomy = Decidim::Taxonomy.find_by(id:, organization:)
          next unless taxonomy

          Decidim::Taxonomization.new(taxonomy:, taxonomizable: nil)
        end.compact
      end
    end
  end
end
