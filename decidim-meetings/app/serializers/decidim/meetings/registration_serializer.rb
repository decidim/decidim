# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      # Serializes a registration
      def serialize
        {
          id: resource.id,
          code: resource.code,
          user: {
            name: resource.user.name,
            email: resource.user.email,
            user_group: resource.user_group&.name || ""
          },
          registration_form_answers: serialize_answers
        }
      end

      private

      def serialize_answers
        questions = resource.meeting.questionnaire.questions
        answers = resource.meeting.questionnaire.answers.where(user: resource.user)
        questions.each_with_index.inject({}) do |serialized, (question, idx)|
          answer = answers.find_by(question: question)
          serialized.update("#{idx + 1}. #{translated_attribute(question.body)}" => normalize_body(answer))
        end
      end

      def normalize_body(answer)
        return "" unless answer

        answer.body || answer.choices.pluck(:body)
      end
    end
  end
end
