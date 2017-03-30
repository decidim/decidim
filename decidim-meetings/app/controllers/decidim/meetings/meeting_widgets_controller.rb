module Decidim
  module Meetings
    class MeetingWidgetsController < Decidim::WidgetsController
      helper_method :model

      private

      def model
        @model ||= Meeting.where(feature: params[:feature_id]).find(params[:meeting_id])
      end
    end
  end
end
