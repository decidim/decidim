# frozen_string_literal: true

module Decidim
  module Meetings
    class CalendarRenderer
      def self.for(resource, filters = nil)
        case resource
        when Decidim::Organization
          Calendar::OrganizationCalendar.for(resource, filters)
        when Decidim::Component
          Calendar::ComponentCalendar.for(resource, filters)
        when Decidim::Meetings::Meeting
          Calendar::MeetingCalendar.for(resource, filters)
        end
      end
    end
  end
end
