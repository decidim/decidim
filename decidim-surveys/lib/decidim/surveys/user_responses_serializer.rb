# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes a Survey so can be exported to CSV, JSON or other
    # formats.
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a collection of Responses.
      def initialize(responses)
        @responses = responses
      end

      # Public: Exports a hash with the serialized data for the user responses.
      def serialize
        @responses.each_with_index.inject({}) do |serialized, (response, idx)|
          serialized.update(
            response_translated_attribute_name(:id) => [response.id, response.user&.id].join("_"),
            response_translated_attribute_name(:created_at) => response.created_at,
            response_translated_attribute_name(:user_status) => response_translated_attribute_name(response.decidim_user_id.present? ? "registered" : "unregistered"),
            "#{I18n.t(:question, scope: "decidim.forms.user_responses_serializer")} #{idx + 1}" => normalize_body(response)
          )
        end
      end

      private

      attr_reader :survey_user_responses
      alias resource survey_user_responses

      def normalize_body(response)
        normalize_choices(response.choices)
      end

      def normalize_choices(choices)
        choices.map do |choice|
          choice.try(:body)
        end.join(", ")
      end

      def response_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.forms.user_responses_serializer")
      end
    end
  end
end
