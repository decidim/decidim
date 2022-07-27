# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe JoinConference do
    subject { described_class.new(conference, registration_type, user) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:organization) { create :organization }
    let!(:conference) { create :conference, organization:, registrations_enabled:, available_slots: }
    let!(:conference_admin) { create :conference_admin, conference: }
    let!(:registration_type) { create :registration_type, conference: }
    let(:user) { create :user, :confirmed, organization: }
    let(:participatory_space_admins) { conference.admins }

    let(:user_notification) do
      {
        event: "decidim.events.conferences.conference_registration_validation_pending",
        event_class: ConferenceRegistrationNotificationEvent,
        resource: conference,
        affected_users: [user]
      }
    end

    let(:admin_notification) do
      {
        event: "decidim.events.conferences.conference_registrations_over_percentage",
        event_class: ConferenceRegistrationsOverPercentageEvent,
        resource: conference,
        followers: participatory_space_admins,
        extra:
      }
    end

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

      it "sends an email with the pending validation" do
        perform_enqueued_jobs { subject.call }

        email = last_email

        expect(email.subject).to include("pending")
        expect(email.body.encoded).to include(translated(registration_type.title))
      end

      it "sends a notification to the user with the pending validation" do
        expect(Decidim::EventsManager).to receive(:publish).with(user_notification)

        subject.call
      end

      context "and exists and invite for the user" do
        let!(:conference_invite) { create(:conference_invite, conference:, user:) }

        it "marks the invite as accepted" do
          expect { subject.call }.to change { conference_invite.reload.accepted_at }.from(nil).to(kind_of(Time))
        end
      end

      context "when the conference available slots are occupied over the 50%" do
        let(:extra) { { percentage: 0.5 } }

        before do
          create_list :conference_registration, (available_slots * 0.5).round - 1, conference:
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

          subject.call
        end

        context "when the 50% is already met" do
          before do
            create :conference_registration, conference:
          end

          it "doesn't notify it twice to the process admins" do
            expect(Decidim::EventsManager).not_to receive(:publish).with(admin_notification)

            subject.call
          end
        end
      end

      context "when the conference available slots are occupied over the 80%" do
        let(:extra) { { percentage: 0.8 } }

        before do
          create_list :conference_registration, (available_slots * 0.8).round - 1, conference:
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

          subject.call
        end

        context "when the 80% is already met" do
          before do
            create_list :conference_registration, (available_slots * 0.8).round, conference:
          end

          it "doesn't notify it twice to the process admins" do
            expect(Decidim::EventsManager).not_to receive(:publish).with(admin_notification)

            subject.call
          end
        end
      end

      context "when the conference available slots are occupied over the 100%" do
        let(:extra) { { percentage: 1 } }

        before do
          create_list :conference_registration, available_slots - 1, conference:
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

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
        create(:conference_registration, conference:)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
