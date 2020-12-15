# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to see attendance logs for a Meeting videoconference
      class VideoconferenceAttendanceLogsController < Admin::ApplicationController
        helper_method :meeting, :logs

        def index
          enforce_permission_to :read_logs, :meeting, meeting: meeting
        end

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def logs
          @logs ||= VideoconferenceAttendanceLog.where(meeting: meeting).page(params[:page]).per(15)
        end
      end
    end
  end
end
