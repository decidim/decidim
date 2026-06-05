# frozen_string_literal: true

module Decidim
  module Surveys
    class UserResponsesSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Exports a hash with the serialized data for the user response.
      def serialize
        # Returns a csv export of surveys responses only if they have been published.
        response = resource
        {
          id: response.session_token,
          created_at: response.created_at,
          ip_hash: response.ip_hash,
          user_status: I18n.t(response.decidim_user_id.present? ? "registered" : "unregistered", scope: "decidim.open_data.help.published_survey_user_responses"),
          question: question_text(response),
          body: normalize_body(response)
        }
      end

      private

      def question_text(response)
        if response.question.present?
          "#{response.question.position}. #{translated_attribute(response.question.body)}"
        else
          ""
        end
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
          attribute[I18n.locale.to_s] || attribute[organization.default_locale] || attribute.values.first
        else
          attribute.to_s
        end
      end

      def organization
        resource.questionnaire.questionnaire_for.organization
      end
    end
  end
end
