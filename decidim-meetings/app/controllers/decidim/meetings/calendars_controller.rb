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
        render plain: CalendarRenderer.for(current_component, params[:filter]), content_type: "type/calendar"
      end

      def meeting_calendar
        send_data CalendarRenderer.for(meeting), content_type: "type/calendar", filename: "#{meeting.reference}.ics"
      end

      private

      def meeting
        @meeting ||= Decidim::Meetings::Meeting.where(component: current_component).find(params[:id])
      end

      def set_default_request_format
        request.format = :text
      end
    end
  end
end
