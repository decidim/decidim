# frozen_string_literal: true

module Decidim
  module Surveys
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Exports a hash with the serialized data for the user response.
      def serialize
        # Use 'resource' which is provided by the parent Serializer class
        response = resource
        return {} unless response

        {
          id: response.session_token,
          created_at: response.created_at,
          ip_hash: response.ip_hash,
          user_status: (response.decidim_user_id.present? ? "Registered" : "Unregistered"),
          question: question_text(response),
          body: normalize_body(response)
        }
      end

      private

      def question_text(response)
        return "Unknown Question" if response.question.present?

        "#{response.question.position}. #{translated_attribute(response.question.body)}"
      end

      def normalize_body(response)
        return response.body if response.body.present?

        normalize_choices(response.choices)
      end

      def normalize_choices(choices)
        choices.map { |choice| translated_attribute(choice.try(:body)) }.compact.join(", ")
      end

      def translated_attribute(attribute)
        if attribute.is_a?(Hash)
          # Get translation for current locale, fallback to English, then first available
          attribute[I18n.locale.to_s] || attribute["en"] || attribute.values.first
        else
          attribute.to_s
        end
      end
    end
  end
end
