# frozen-string_literal: true

module Decidim
  module Meetings
    class RegistrationCodeValidatedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :registration_code

      def resource_text
        translated_attribute(resource.description)
      end

      private

      def registration_code
        extra["registration"]["code"]
      end
    end
  end
end
