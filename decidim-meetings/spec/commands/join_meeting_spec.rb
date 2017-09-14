# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::JoinMeeting do
  let(:registrations_enabled) { true }
  let(:available_slots) { 10 }
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:process_admin) { create :user, :process_admin, participatory_process: participatory_process }
  let(:feature) { create :feature, manifest_name: :meetings, participatory_space: participatory_process }
  let(:meeting) { create :meeting, feature: feature, registrations_enabled: registrations_enabled, available_slots: available_slots }
  let(:user) { create :user, :confirmed, organization: organization }
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

    context "when the meeting available slots are occupied over the 50%" do
      before do
        create_list :registration, (available_slots * 0.5).round - 1, meeting: meeting
      end

      it "notifies it to the process admins" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_registrations_over_percentage",
            event_class: Decidim::Meetings::MeetingRegistrationsOverPercentageEvent,
            resource: meeting,
            recipient_ids: [process_admin.id],
            extra: {
              percentage: 0.5
            }
          )

        subject.call
      end

      context "when the 50% is already met" do
        before do
          create :registration, meeting: meeting
        end

        it "doesn't notify it twice" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)

          subject.call
        end
      end
    end

    context "when the meeting available slots are occupied over the 80%" do
      before do
        create_list :registration, (available_slots * 0.8).round - 1, meeting: meeting
      end

      it "notifies it to the process admins" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_registrations_over_percentage",
            event_class: Decidim::Meetings::MeetingRegistrationsOverPercentageEvent,
            resource: meeting,
            recipient_ids: [process_admin.id],
            extra: {
              percentage: 0.8
            }
          )

        subject.call
      end

      context "when the 80% is already met" do
        before do
          create_list :registration, (available_slots * 0.8).round, meeting: meeting
        end

        it "doesn't notify it twice" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)

          subject.call
        end
      end
    end

    context "when the meeting available slots are occupied over the 100%" do
      before do
        create_list :registration, available_slots - 1, meeting: meeting
      end

      it "notifies it to the process admins" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_registrations_over_percentage",
            event_class: Decidim::Meetings::MeetingRegistrationsOverPercentageEvent,
            resource: meeting,
            recipient_ids: [process_admin.id],
            extra: {
              percentage: 1
            }
          )

        subject.call
      end
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
