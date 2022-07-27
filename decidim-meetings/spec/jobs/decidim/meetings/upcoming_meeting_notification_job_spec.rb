# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::UpcomingMeetingNotificationJob do
  subject { described_class }

  let(:organization) { create :organization }
  let(:user) { create :user, organization: }
  let(:start_time) { 1.day.from_now }
  let(:participatory_space) { create :participatory_process, organization: }
  let(:component) { create :component, manifest_name: :meetings, participatory_space: }
  let(:meeting) { create :meeting, start_time: }
  let!(:checksum) { subject.generate_checksum(meeting) }
  let!(:follow) { create :follow, followable: meeting, user: }

  context "when the checksum is correct" do
    it "notifies the upcoming meeting" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.meetings.upcoming_meeting",
          event_class: Decidim::Meetings::UpcomingMeetingEvent,
          resource: meeting,
          followers: [user]
        )

      subject.perform_now(meeting.id, checksum)
    end
  end

  context "when the checksum is not correct" do
    let(:checksum) { "1234" }

    it "doesn't notify the upcoming meeting" do
      expect(Decidim::EventsManager)
        .not_to receive(:publish)

      subject.perform_now(meeting.id, checksum)
    end
  end

  context "when the meeting is hidden" do
    let!(:moderation) { create(:moderation, reportable: meeting, report_count: 1, hidden_at: Time.current) }

    it "doesn't notify the upcoming meeting" do
      expect(Decidim::EventsManager)
        .not_to receive(:publish)

      subject.perform_now(meeting.id, checksum)
    end
  end

  context "when the meeting is withdrawn" do
    let(:meeting) { create :meeting, :withdrawn, start_time: }

    it "doesn't notify the upcoming meeting" do
      expect(Decidim::EventsManager)
        .not_to receive(:publish)

      subject.perform_now(meeting.id, checksum)
    end
  end
end
