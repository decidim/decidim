# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes a Survey so it can be exported to CSV, JSON or other formats.
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Exports a hash with the serialized data for the user response.
      def serialize
        {
          response_translated_attribute_name(:id) => [resource.id, resource.user&.id].compact.join("_"),
          response_translated_attribute_name(:created_at) => resource.created_at,
          response_translated_attribute_name(:user_status) => response_translated_attribute_name(resource.decidim_user_id.present? ? "registered" : "unregistered"),
          response_translated_attribute_name(:body) => normalize_body(resource)
        }
      end

      private

      def normalize_body(response)
        return response.body if response.body.present?

        normalize_choices(response.choices)
      end

      def normalize_choices(choices)
        choices.map { |choice| choice.try(:body) }.compact.join(", ")
      end

      def response_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.open_data.help.survey_user_responses")
      end
    end
  end
end
