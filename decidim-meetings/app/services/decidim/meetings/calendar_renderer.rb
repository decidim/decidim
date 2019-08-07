# frozen_string_literal: true

module Decidim
  module Meetings
    class CalendarRenderer
      def self.for(resource)
        case resource
        when Decidim::Organization
          Calendar::OrganizationCalendar.for(resource)
        when Decidim::Component
          Calendar::ComponentCalendar.for(resource)
        end
      end
    end
  end
end
