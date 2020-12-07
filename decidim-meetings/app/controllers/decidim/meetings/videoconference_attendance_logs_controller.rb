# frozen_string_literal: true

module Decidim
  module Meetings
    class VideoconferenceAttendanceLogsController < Decidim::WidgetsController
      helper MeetingsHelper

      def create
        data = {
          room_name: params["roomName"],
          user_videoconference_id: params["id"],
          user_display_name: params["displayName"],
          event: params["event"]
        }

        CreateVideoconferenceAttendanceLog.call(meeting, current_user, data) do
          on(:ok) do
            render json: {
              error: I18n.t("videoconference_attendance_logs.create.success", scope: "decidim.meetings")
            }, status: :ok
          end
          
          on(:invalid) do
            render json: {
              error: I18n.t("videoconference_attendance_logs.create.error", scope: "decidim.meetings")
            }, status: :unprocessable_entity
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.where(component: params[:component_id]).find(params[:meeting_id])
      end
    end
  end
end
