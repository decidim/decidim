# frozen_string_literal: true

module Decidim
  module Forms
    class DataPortabilityUserAnswersSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      # Serializes an user answer for data portability
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          questionnaire: {
            id: resource.question.questionnaire.id,
            title: translated_attribute(resource.question.questionnaire.title),
            description: translated_attribute(resource.question.questionnaire.description),
            tos: translated_attribute(resource.question.questionnaire.tos)
          },
          question: {
            id: resource.question.id,
            body: translated_attribute(resource.question.body),
            description: translated_attribute(resource.question.description)
          },
          answer: normalize_body(resource)
        }
      end

      private

      def normalize_body(resource)
        attachments_for(resource) || resource.body || resource.choices.pluck(:body)
      end

      def attachments_for(resource)
        return if resource.attachments.blank?

        resource.attachments.map(&:url)
      end
    end
  end
end
