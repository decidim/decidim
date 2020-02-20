# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resources as an .ics file so users can import them
    # to their favorite calendar app
    class CalendarsController < Decidim::Meetings::ApplicationController
      layout false
      helper_method :meetings
      before_action :set_default_request_format
      skip_around_action :use_organization_time_zone

      def show
        render plain: CalendarRenderer.for(current_component), content_type: "type/calendar"
      end

      private

      def set_default_request_format
        request.format = :text
      end
    end
  end
end
