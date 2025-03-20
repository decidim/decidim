# frozen_string_literal: true

module Decidim
  module Meetings
    class DownloadYourDataUserAnswersSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      # Serializes an user answer for download your data
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name,
            email: resource.user.email
          },
          questionnaire: {
            id: resource.question.questionnaire.id
          },
          question: {
            id: resource.question.id,
            body: translated_attribute(resource.question.body)
          },
          answer: normalize_body(resource)
        }
      end

      private

      def normalize_body(resource)
        resource.choices.pluck(:body)
      end
    end
  end
end
