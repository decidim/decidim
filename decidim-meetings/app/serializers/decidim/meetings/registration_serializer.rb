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
          registration_form_responses: serialize_responses
        }
      end

      private

      def serialize_responses
        return [] unless resource.meeting.questionnaire

        Decidim::Forms::UserResponsesSerializer.new(
          resource.meeting.questionnaire.responses.where(user: resource.user)
        ).serialize
      end
    end
  end
end
