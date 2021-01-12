# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe VideoconferenceAttendanceLog do
      subject { videoconference_attendance_log }

      let(:videoconference_attendance_log) { build_stubbed(:videoconference_attendance_log) }

      it { is_expected.to be_valid }

      it "has an associated meeting" do
        expect(videoconference_attendance_log.meeting).to be_a(Decidim::Meetings::Meeting)
      end

      it "has an associated user" do
        expect(videoconference_attendance_log.user).to be_a(Decidim::User)
      end

      context "without a meeting" do
        let(:videoconference_attendance_log) { build :videoconference_attendance_log, meeting: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a user" do
        let(:videoconference_attendance_log) { build :videoconference_attendance_log, user: nil }

        it { is_expected.to be_valid }
      end

      context "without a room_name" do
        let(:videoconference_attendance_log) { build :videoconference_attendance_log, room_name: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a user_videoconference_id" do
        let(:videoconference_attendance_log) { build :videoconference_attendance_log, user_videoconference_id: nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
