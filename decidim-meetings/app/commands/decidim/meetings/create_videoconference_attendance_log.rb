# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user or leaves an embedded
    # online meeting videoconference
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
        begin
          create_videoconference_attendance_log!
        rescue StandardError
          return broadcast(:invalid)
        end
        broadcast(:ok)
      end

      private

      attr_reader :meeting, :user, :data

      def create_videoconference_attendance_log!
        id = data.delete(:user_videoconference_id)

        attributes = {
          meeting: meeting,
          user: user,
          user_videoconference_id: id,
          room_name: data.delete(:room_name) || join_log_for(id).room_name,
          user_display_name: data.delete(:user_display_name) || join_log_for(id).user_display_name,
          event: data.delete(:event),
          extra: data
        }

        VideoconferenceAttendanceLog.create!(attributes)
      end

      def join_log_for(id)
        VideoconferenceAttendanceLog.find_by(event: "join", user_videoconference_id: id)
      end
    end
  end
end
