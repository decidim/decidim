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
            email: resource.user.email
          },
          registration_form_answers: serialize_answers
        }
      end

      private

      def serialize_answers
        Decidim::Forms::UserAnswersSerializer.new(
          resource.meeting.questionnaire.answers.where(user: resource.user)
        ).serialize
      end
    end
  end
end
