module Decidim
  module Meetings
    class MeetingWidgetsController < Decidim::WidgetsController
      helper_method :model, :current_participatory_process

      private

      def model
        @model ||= Meeting.where(feature: params[:feature_id]).find(params[:meeting_id])
      end

      def current_participatory_process
        @current_participatory_process ||= model.feature.participatory_process
      end
    end
  end
end
