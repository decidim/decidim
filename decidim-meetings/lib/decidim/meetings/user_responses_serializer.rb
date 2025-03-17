# frozen_string_literal: true

module Decidim
  module Meetings
    # This class serializes the responses given by a User for questionnaire so can be
    # exported to CSV, JSON or other formats.
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
            response_translated_attribute_name(:id) => [response.id, response.user.id].join("_"),
            response_translated_attribute_name(:created_at) => response.created_at,
            response_translated_attribute_name(:user_status) => response_translated_attribute_name(response.decidim_user_id.present? ? "registered" : "unregistered"),
            "#{idx + 1}. #{translated_attribute(response.question.body)}" => normalize_body(response)
          )
        end
      end

      private

      attr_reader :responses
      alias resource responses

      def normalize_body(response)
        normalize_choices(response.choices)
      end

      def normalize_choices(choices)
        choices.map do |choice|
          choice.try(:body)
        end
      end

      def response_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: "decidim.forms.user_responses_serializer")
      end
    end
  end
end
