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
            title: translated(resource.question.questionnaire, :title),
            description: translated(resource.question.questionnaire, :description),
            tos: translated(resource.question.questionnaire, :tos)
          },
          question: {
            id: resource.question.id,
            body: translated(resource.question, :body),
            description: translated(resource.question, :description)
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
