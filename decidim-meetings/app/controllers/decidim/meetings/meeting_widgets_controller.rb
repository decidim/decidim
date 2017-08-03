# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingWidgetsController < Decidim::WidgetsController
      helper MeetingsHelper

      private

      def model
        @model ||= Meeting.where(feature: params[:feature_id]).find(params[:meeting_id])
      end

      def iframe_url
        @iframe_url ||= meeting_meeting_widget_url(model)
      end
    end
  end
end
