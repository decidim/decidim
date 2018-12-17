# frozen-string_literal: true

module Decidim
  module Meetings
    class CloseMeetingEvent < Decidim::Events::SimpleEvent
      def resource_text
        translated_attribute(resource.description)
      end

      def event_has_roles?
        true
      end
    end
  end
end
