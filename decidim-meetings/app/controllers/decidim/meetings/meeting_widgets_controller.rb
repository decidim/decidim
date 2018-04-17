# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingWidgetsController < Decidim::WidgetsController
      helper MeetingsHelper
      helper Decidim::SanitizeHelper

      private

      def model
        @model ||= Meeting.where(component: params[:component_id]).find(params[:meeting_id])
      end

      def iframe_url
        @iframe_url ||= meeting_meeting_widget_url(model)
      end
    end
  end
end
