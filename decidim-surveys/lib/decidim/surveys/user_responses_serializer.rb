# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes a Survey so it can be exported to CSV, JSON or other formats.
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Exports a hash with the serialized data for the user response.
      def serialize
        {
          id: [resource.id, resource.user&.id].compact.join("_"),
          created_at: resource.created_at,
          user_status: resource.decidim_user_id.present? ? "Registered" : "Unregistered",
          question: translated_attribute(resource.question.body),
          body: normalize_body(resource)
        }
      end

      private

      def normalize_body(response)
        normalize_choices(response.choices)
      end

      def normalize_choices(choices)
        choices.map { |choice| choice.try(:body) }.compact.join(", ")
      end

      def response_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.forms.user_responses_serializer")
      end
    end
  end
end
