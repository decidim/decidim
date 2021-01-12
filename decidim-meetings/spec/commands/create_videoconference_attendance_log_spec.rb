# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CreateVideoconferenceAttendanceLog do
    subject { described_class.new(meeting, user, data) }

    let(:user) { nil }
    let(:meeting) { create(:meeting, embedded_videoconference: true) }
    let(:event) { "join" }
    let(:data) do
      {
        meeting: meeting,
        user: user,
        room_name: "test-room-name",
        user_display_name: user&.name || "display-name",
        user_videoconference_id: "user-videoconference-id",
        event: event
      }
    end

    context "when data is not valid" do
      let(:meeting) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:videoconference_attendance_log) { VideoconferenceAttendanceLog.last }

      it "creates the attendance log" do
        expect { subject.call }.to change(VideoconferenceAttendanceLog, :count).by(1)
      end

      it "sets the meeting" do
        subject.call
        expect(videoconference_attendance_log.meeting).to eq meeting
      end

      context "when the user is present" do
        let(:user) { create :user, :confirmed }

        it "sets the user" do
          subject.call
          expect(videoconference_attendance_log.user).to eq user
          expect(videoconference_attendance_log.user_display_name).to eq user.name
          expect(videoconference_attendance_log.user_videoconference_id).to eq "user-videoconference-id"
        end
      end

      context "when the user is not present" do
        let(:user) { nil }

        it "sets the display name" do
          subject.call
          expect(videoconference_attendance_log.user_display_name).to eq "display-name"
          expect(videoconference_attendance_log.user_videoconference_id).to eq "user-videoconference-id"
        end
      end

      it "sets the event" do
        subject.call
        expect(videoconference_attendance_log.event).to eq event
      end

      context "when data has no user_display_name and room_name information" do
        let(:user_videoconference_id) { "test-user-id" }

        let!(:last_videoconference_attendance_log) do
          create(
            :videoconference_attendance_log,
            room_name: "wonderland",
            meeting: meeting,
            user: user,
            user_videoconference_id: user_videoconference_id,
            user_display_name: "alice",
            event: "join"
          )
        end

        let(:data) do
          {
            meeting: meeting,
            user: user,
            user_videoconference_id: user_videoconference_id,
            event: "leave"
          }
        end

        it "gets the info from the last join event for the user_videoconference_id" do
          subject.call
          expect(videoconference_attendance_log.user_display_name).to eq "alice"
          expect(videoconference_attendance_log.room_name).to eq "wonderland"
        end
      end
    end
  end
end
