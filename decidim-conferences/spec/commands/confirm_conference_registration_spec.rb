# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::ConfirmConferenceRegistration do
    subject { described_class.new(conference_registration, current_user) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:organization) { create :organization }
    let!(:conference) { create :conference, organization:, registrations_enabled:, available_slots: }
    let!(:current_user) { create :conference_admin, conference: }
    let!(:registration_type) { create :registration_type, conference: }
    let(:user) { create :user, :confirmed, organization: }
    let!(:conference_registration) { create :conference_registration, :unconfirmed, conference:, registration_type:, user: }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "confirms the conference registration for the user" do
        subject.call
        conference_registration.reload

        expect(conference_registration.user).to eq(user)
        expect(conference_registration.conference).to eq(conference)
        expect(conference_registration).to be_confirmed
      end

      it "sends an email confirming the registration" do
        perform_enqueued_jobs { subject.call }

        email = last_email

        expect(email.subject).to include("confirmed")

        attachment = email.attachments.first
        expect(attachment.read.length).to be_positive
        expect(attachment.mime_type).to eq("text/calendar")
        expect(attachment.filename).to match(/conference-calendar-info.ics/)
      end

      it "sends a notification to the user with the pending validation" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.conferences.conference_registration_confirmed",
            event_class: Decidim::Conferences::ConferenceRegistrationNotificationEvent,
            resource: conference,
            affected_users: [user]
          )

        subject.call
      end
    end
  end
end
