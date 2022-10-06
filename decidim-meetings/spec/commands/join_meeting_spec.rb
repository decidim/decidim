# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe JoinMeeting do
    subject { described_class.new(meeting, user, registration_form) }

    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create :component, manifest_name: :meetings, participatory_space: participatory_process }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:questionnaire) { nil }

    let(:meeting) do
      create(:meeting,
             component:,
             registrations_enabled:,
             available_slots:,
             questionnaire:)
    end

    let(:user) { create :user, :confirmed, organization:, notifications_sending_frequency: "none" }

    let(:registration_form) { Decidim::Meetings::JoinMeetingForm.new }

    let(:badge_notification) { hash_including(event: "decidim.events.gamification.badge_earned") }
    let(:user_notification) do
      {
        event: "decidim.events.meetings.meeting_registration_confirmed",
        event_class: MeetingRegistrationNotificationEvent,
        resource: meeting,
        affected_users: [user],
        extra: { registration_code: kind_of(String) }
      }
    end

    let(:process_admin) { create :process_admin, participatory_process: }
    let(:admin_notification) do
      {
        event: "decidim.events.meetings.meeting_registrations_over_percentage",
        event_class: MeetingRegistrationsOverPercentageEvent,
        resource: meeting,
        affected_users: [process_admin],
        extra:
      }
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a registration for the meeting and the user no public participation" do
        expect { subject.call }.to change(Registration, :count).by(1)
        last_registration = Registration.last
        expect(last_registration.user).to eq(user)
        expect(last_registration.meeting).to eq(meeting)
        expect(last_registration.public_participation).to be false
      end

      context "when the form has public_participation set to true" do
        before do
          registration_form.public_participation = true
        end

        it "creates a registration for the meeting and the user with public participation" do
          expect { subject.call }.to change(Registration, :count).by(1)
          last_registration = Registration.last
          expect(last_registration.user).to eq(user)
          expect(last_registration.meeting).to eq(meeting)
          expect(last_registration.public_participation).to be true
        end
      end

      context "when registration code is enabled" do
        let(:component) do
          create :component,
                 manifest_name: :meetings,
                 participatory_space: participatory_process,
                 settings: {
                   registration_code_enabled: true
                 }
        end

        it "sends an email confirming the registration" do
          perform_enqueued_jobs { subject.call }

          email = last_email
          email_body = last_email_body
          last_registration = Registration.last
          expect(email.subject).to include("confirmed")
          expect(email_body).to include(last_registration.code)

          attachment = email.attachments.first
          expect(attachment.read.length).to be_positive
          expect(attachment.mime_type).to eq("text/calendar")
          expect(attachment.filename).to match(/meeting-calendar-info.ics/)
        end
      end

      context "when registration code is disabled" do
        before do
          component.update!(settings: { registration_code_enabled: false })
        end

        it "sends an email confirming the registration" do
          perform_enqueued_jobs { subject.call }

          email = last_email
          email_body = last_email_body
          last_registration = Registration.last
          expect(email.subject).to include("confirmed")
          expect(email_body).not_to include(last_registration.code)

          attachment = email.attachments.first
          expect(attachment.read.length).to be_positive
          expect(attachment.mime_type).to eq("text/calendar")
          expect(attachment.filename).to match(/meeting-calendar-info.ics/)
        end
      end

      it "sends a notification to the user with the registration confirmed" do
        expect(Decidim::EventsManager).to receive(:publish).with(badge_notification)
        expect(Decidim::EventsManager).to receive(:publish).with(user_notification)

        subject.call
      end

      it "increases the user's score" do
        expect { subject.call }.to change { Decidim::Gamification.status_for(user, :attended_meetings).score }.from(0).to(1)
      end

      it "makes the user follow the meeting" do
        expect { subject.call }.to change { Decidim::Follow.where(user:, followable: meeting).count }.from(0).to(1)
      end

      context "and exists an invite for the user" do
        let!(:invite) { create(:invite, meeting:, user:) }

        it "marks the invite as accepted" do
          expect { subject.call }.to change { invite.reload.accepted_at }.from(nil).to(kind_of(Time))
        end
      end

      context "when the meeting available slots are occupied over the 50%" do
        let(:extra) { { percentage: 0.5 } }

        before do
          create_list :registration, (available_slots * 0.5).round - 1, meeting:
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(badge_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

          subject.call
        end

        context "when the 50% is already met" do
          before do
            create :registration, meeting:
          end

          it "doesn't notify it twice" do
            expect(Decidim::EventsManager).not_to receive(:publish).with(admin_notification)

            subject.call
          end
        end
      end

      context "when the meeting available slots are occupied over the 80%" do
        let(:extra) { { percentage: 0.8 } }

        before do
          create_list :registration, (available_slots * 0.8).round - 1, meeting:
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(badge_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

          subject.call
        end

        context "when the 80% is already met" do
          before do
            create_list :registration, (available_slots * 0.8).round, meeting:
          end

          it "doesn't notify it twice" do
            expect(Decidim::EventsManager).not_to receive(:publish).with(admin_notification)

            subject.call
          end
        end
      end

      context "when the meeting available slots are occupied over the 100%" do
        let(:extra) { { percentage: 1 } }

        before do
          create_list :registration, available_slots - 1, meeting:
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(badge_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

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
        create(:registration, meeting:)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the user has already registered for the meeting" do
      before do
        create(:registration, meeting:, user:)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the registration form is a questionnaire" do
      let!(:questionnaire) { create(:questionnaire) }
      let!(:question) { create(:questionnaire_question, questionnaire:) }
      let(:session_token) { "some-token" }
      let(:registration_form) { Decidim::Forms::QuestionnaireForm.from_model(questionnaire).with_context(session_token:) }

      context "and the registration form is invalid" do
        it "broadcast invalid_form" do
          expect { subject.call }.to broadcast(:invalid_form)
        end
      end

      context "and everything is ok" do
        before do
          registration_form.tos_agreement = true
          registration_form.responses.first.body = "My answer response"
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "saves the answers" do
          expect { subject.call }.to change(Decidim::Forms::Answer, :count).by(1)

          answer = Decidim::Forms::Answer.last
          expect(answer.user).to eq(user)
          expect(answer.body).to eq("My answer response")
        end

        it "creates a registration for the meeting and the user with no public participation" do
          expect { subject.call }.to change(Registration, :count).by(1)
          last_registration = Registration.last
          expect(last_registration.user).to eq(user)
          expect(last_registration.meeting).to eq(meeting)
          expect(last_registration.public_participation).to be false
        end

        context "when the form has public_participation set to true" do
          before do
            registration_form.tos_agreement = true
            registration_form.responses.first.body = "My answer response"
            registration_form.public_participation = true
          end

          it "creates a registration for the meeting and the user with public participation" do
            expect { subject.call }.to change(Registration, :count).by(1)
            last_registration = Registration.last
            expect(last_registration.user).to eq(user)
            expect(last_registration.meeting).to eq(meeting)
            expect(last_registration.public_participation).to be true
          end
        end
      end
    end
  end
end
