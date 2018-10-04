# frozen_string_literal: true

module Decidim
  module Surveys
    class DataPortabilitySurveyUserAnswersSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      # Serializes a Survey User Answer for data portability
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          survey: {
            id: resource.question.survey.id,
            title: translated_attribute(resource.question.survey.title),
            description: translated_attribute(resource.question.survey.description),
            tos: translated_attribute(resource.question.survey.tos)
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
        resource.body || resource.choices.pluck(:body)
      end
    end
  end
end
