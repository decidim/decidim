# frozen-string_literal: true

module Decidim
  module Debates
    class CloseDebateEvent < Decidim::Events::SimpleEvent
      def resource_text
        translated_attribute(resource.conclusions)
      end

      def event_has_roles?
        true
      end
    end
  end
end
