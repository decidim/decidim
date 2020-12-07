# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user joins an embedded online
    # meeting videoconference
    class CreateVideoconferenceAttendanceLog < Rectify::Command
      def initialize(meeting, user, data)
        @meeting = meeting
        @user = user
        @data = data
      end

      # Creates the videoconference attendance if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if false # TODO
        
        create_videoconference_attendance_log!

        broadcast(:ok, videoconference_attendance)
      end

      private

      attr_reader :meeting, :user, :data

      def create_videoconference_attendance_log!
        attributes = {
          meeting: meeting,
          user: user,
          user_videoconference_id: data.delete(:user_videoconference_id),
          user_display_name: data.delete(:user_display_name),
          room_name: data.delete(:room_name),
          event: data.delete(:event),
          extra: data
        }

        attendance.update!(attributes)
      end

      def attendance
        Decidim::Meetings::VideoconferenceAttendanceLog.find_or_create_by(
          meeting: meeting,
          user_videoconference_id: data[:user_videoconference_id]
        )
      end
    end
  end
end
