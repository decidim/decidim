# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes a Survey so it can be exported to CSV, JSON or other formats.
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Exports a hash with the serialized data for the user response.
      def serialize
        responses_hash = hash_for(@responses.first)
        responses_hash.merge!(questions_hash)

        @responses.each do |response|
          responses_hash[translated_question_key(response.question.position, response.question.body)] = normalize_body(response)
        end

        responses_hash
      end

      private

      def hash_for(response)
        {
          response_translated_attribute_name(:id) => response&.session_token,
          response_translated_attribute_name(:created_at) => response&.created_at,
          response_translated_attribute_name(:ip_hash) => response&.ip_hash,
          response_translated_attribute_name(:user_status) => response_translated_attribute_name(response&.decidim_user_id.present? ? "registered" : "unregistered")
        }
      end

      def normalize_body(response)
        return response.body if response.body.present?

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
