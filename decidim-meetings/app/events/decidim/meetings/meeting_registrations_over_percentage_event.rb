# frozen-string_literal: true

module Decidim
  module Meetings
    class MeetingRegistrationsOverPercentageEvent < Decidim::Events::SimpleEvent
      i18n_attributes :percentage

      def resource_text
        translated_attribute(resource.description)
      end

      def percentage
        extra["percentage"] * 100
      end
    end
  end
end
