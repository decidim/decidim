# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::JoinMeeting do
  let(:registrations_enabled) { true }
  let(:available_slots) { 10 }
  let(:meeting) { create :meeting, registrations_enabled: registrations_enabled, available_slots: available_slots }
  let(:user) { create :user, :confirmed, organization: meeting.organization }
  subject { described_class.new(meeting, user) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates a registration for the meeting and the user" do
      expect { subject.call }.to change { Decidim::Meetings::Registration.count }.by(1)
      last_registration = Decidim::Meetings::Registration.last
      expect(last_registration.user).to eq(user)
      expect(last_registration.meeting).to eq(meeting)
    end

    it "sends an email confirming the registration" do
      perform_enqueued_jobs { subject.call }

      email = last_email
      expect(email.subject).to include("confirmed")
      attachment = email.attachments.first

      expect(attachment.read.length).to be_positive
      expect(attachment.mime_type).to eq("text/calendar")
      expect(attachment.filename).to match(/meeting-calendar-info.ics/)
    end
  end

  context "when the meeting has not registrations enabled" do
    let(:registrations_enabled) { false }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the meeting has not enough available slots" do
    let(:available_slots) { 1 }

    before do
      create(:registration, meeting: meeting)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
