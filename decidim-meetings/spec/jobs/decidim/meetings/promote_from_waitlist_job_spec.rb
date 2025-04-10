# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::PromoteFromWaitlistJob do
  subject { described_class }

  let!(:meeting) { create(:meeting, :with_registrations_enabled, available_slots: 11, reserved_slots: 2) }
  let!(:registered_users) { create_list(:registration, 8, meeting:, status: :registered) }
  let!(:registration_on_waitlist) { create(:registration, meeting:, status: :waiting_list) }

  it "promotes one user from the waitlist to registered" do
    expect do
      subject.perform_now(meeting.id)
    end.to change { meeting.registrations.registered.count }
      .by(1)
      .and change { meeting.registrations.waiting_list.count }
      .by(-1)

    promoted = meeting.registrations.find_by(user: registration_on_waitlist.user)
    expect(promoted.status).to eq("registered")
  end

  it "sends a confirmation email to the promoted user" do
    expect(Decidim::Meetings::RegistrationMailer)
      .to receive(:confirmation)
      .with(registration_on_waitlist.user, meeting, instance_of(Decidim::Meetings::Registration))
      .and_call_original

    subject.perform_now(meeting.id)
  end

  it "publishes an internal notification" do
    expect(Decidim::EventsManager).to receive(:publish).with(
      event: "decidim.events.meetings.meeting_registration_confirmed",
      event_class: Decidim::Meetings::MeetingRegistrationNotificationEvent,
      resource: meeting,
      affected_users: [registration_on_waitlist.user],
      extra: hash_including(registration_code: registration_on_waitlist.code)
    )

    subject.perform_now(meeting.id)
  end

  context "when the meeting has no remaining slots" do
    before do
      meeting.update!(available_slots: 8, reserved_slots: 2)
    end

    it "does not promote any user" do
      expect do
        subject.perform_now(meeting.id)
      end.not_to(change { meeting.registrations.registered.count })
    end
  end
end
