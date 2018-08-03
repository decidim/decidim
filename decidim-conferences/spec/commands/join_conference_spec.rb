# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe JoinConference do
    subject { described_class.new(conference, user) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:organization) { create :organization }
    let!(:conference) { create :conference, organization: organization, registrations_enabled: registrations_enabled, available_slots: available_slots }
    let!(:conference_admin) { create :conference_admin, conference: conference }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:participatory_space_admins) { conference.admins }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a registration for the conference and the user" do
        expect { subject.call }.to change(ConferenceRegistration, :count).by(1)
        last_registration = ConferenceRegistration.last
        expect(last_registration.user).to eq(user)
        expect(last_registration.conference).to eq(conference)
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

      context "and exists and invite for the user" do
        let!(:conference_invite) { create(:conference_invite, conference: conference, user: user) }

        it "marks the invite as accepted" do
          expect { subject.call }.to change { conference_invite.reload.accepted_at }.from(nil).to(kind_of(Time))
        end
      end

      context "when the conference available slots are occupied over the 50%" do
        before do
          create_list :conference_registration, (available_slots * 0.5).round - 1, conference: conference
        end

        it "notifies it to the process admins" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.conferences.conference_registrations_over_percentage",
              event_class: ConferenceRegistrationsOverPercentageEvent,
              resource: conference,
              recipient_ids: participatory_space_admins.pluck(:id),
              extra: {
                percentage: 0.5
              }
            )

          subject.call
        end

        context "when the 50% is already met" do
          before do
            create :conference_registration, conference: conference
          end

          it "doesn't notify it twice" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.call
          end
        end
      end

      context "when the conference available slots are occupied over the 80%" do
        before do
          create_list :conference_registration, (available_slots * 0.8).round - 1, conference: conference
        end

        it "notifies it to the process admins" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.conferences.conference_registrations_over_percentage",
              event_class: ConferenceRegistrationsOverPercentageEvent,
              resource: conference,
              recipient_ids: participatory_space_admins.pluck(:id),
              extra: {
                percentage: 0.8
              }
            )

          subject.call
        end

        context "when the 80% is already met" do
          before do
            create_list :conference_registration, (available_slots * 0.8).round, conference: conference
          end

          it "doesn't notify it twice" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.call
          end
        end
      end

      context "when the conference available slots are occupied over the 100%" do
        before do
          create_list :conference_registration, available_slots - 1, conference: conference
        end

        it "notifies it to the process admins" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.conferences.conference_registrations_over_percentage",
              event_class: ConferenceRegistrationsOverPercentageEvent,
              resource: conference,
              recipient_ids: participatory_space_admins.pluck(:id),
              extra: {
                percentage: 1
              }
            )

          subject.call
        end
      end
    end

    context "when the conference has not registrations enabled" do
      let(:registrations_enabled) { false }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the conference has not enough available slots" do
      let(:available_slots) { 1 }

      before do
        create(:conference_registration, conference: conference)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
