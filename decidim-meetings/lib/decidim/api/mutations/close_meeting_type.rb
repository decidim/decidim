# frozen_string_literal: true

module Decidim
  module Meetings
    class CloseMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "CloseMeeting"

      description "Closes a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, CloseMeetingAttributes, description: "Input attributes for closing a meeting", required: true
      argument :locale, GraphQL::Types::String, "The locale to use for the mutation", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        closing_report = attributes.to_h.fetch(:closing_report, object.closing_report)
        attendees_count = attributes.to_h.fetch(:attendees_count, object.attendees_count)
        proposal_ids = Array(attributes.to_h.fetch(:proposal_ids, [])).map(&:to_i)
        closed_at = attributes.to_h.fetch(:closed_at, Time.current)

        params = {
          closing_report:,
          attendees_count:,
          proposal_ids:,
          closed_at:,
          proposals: object.sibling_scope(:proposals)
        }

        form = form(Decidim::Meetings::CloseMeetingForm).from_params(params)

        CloseMeeting.call(form, object) do
          on(:ok) do
            return object.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless [
          super,
          allowed_to?(:close, :meeting, object, context),
          object.published?,
          object.closed? == false,
          object.withdrawn? == false
        ].all?

        true
      end
    end
  end
end
