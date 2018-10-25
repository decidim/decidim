# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resources as an .ics file so users can import them
    # to their favorite calendar app
    class CalendarsController < Decidim::Meetings::ApplicationController
      layout false
      helper_method :meetings
      before_action :set_default_request_format

      def show
        # TODO: add `content_type: "type/calendar"` before finishing
        render plain: Calendar.for(current_component)
      end

      private

      def set_default_request_format
        request.format = :text
      end
    end
  end
end
