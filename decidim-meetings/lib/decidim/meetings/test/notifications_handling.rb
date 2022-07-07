# frozen_string_literal: true

shared_examples_for "emits an upcoming notificaton" do
  context "when it's a future meeting" do
    let(:future_start_date) { 3.days.from_now }

    before do
      meeting.start_time = future_start_date
    end

    it "schedules a upcoming meeting notification job 48h before start time" do
      expect(Decidim::Meetings::UpcomingMeetingNotificationJob)
        .to receive(:generate_checksum).and_return "1234"

      expect(Decidim::Meetings::UpcomingMeetingNotificationJob)
        .to receive_message_chain(:set, :perform_later)
        .with(set: meeting.start_time - Decidim::Meetings.upcoming_meeting_notification)
        .with(kind_of(Integer), "1234")

      subject.call
    end
  end

  context "when it's a past meeting" do
    let(:past_start_date) { 1.day.ago }

    before do
      meeting.start_time = past_start_date
    end

    it "doesn't schedule an upcoming meeting notification" do
      expect(Decidim::Meetings::UpcomingMeetingNotificationJob).not_to receive(:generate_checksum)
      expect(Decidim::Meetings::UpcomingMeetingNotificationJob).not_to receive(:set)
      expect(Decidim::Meetings::UpcomingMeetingNotificationJob).not_to receive(:perform_later)

      subject.call
    end
  end
end
