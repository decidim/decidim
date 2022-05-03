# frozen_string_literal: true

module Decidim
  module Meetings
    module Calendar
      # This class handles how to convert an organization meetings to the
      # ICalendar format. It finds the public meeting components for that
      # organization and delegates the work to the `ComponentCalendar` class.
      class OrganizationCalendar < BaseCalendar
        # Renders the meetings in an ICalendar format. It caches the results in
        # Rails' cache.
        #
        # Returns a String.
        def events
          @events ||= components.map do |component|
            ComponentCalendar.new(component, @filters).events
          end.compact.join
        end

        private

        alias organization resource

        # Finds the component meetings.
        #
        # Returns a collection of Meetings.
        def components
          Decidim::PublicComponents.for(organization, manifest_name: :meetings)
        end
      end
    end
  end
end
