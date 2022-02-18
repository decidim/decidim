# frozen-string_literal: true

module Decidim
  module Meetings
    class CloseMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent

      def event_has_roles?
        true
      end
    end
  end
end
