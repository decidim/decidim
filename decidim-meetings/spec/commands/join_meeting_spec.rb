# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe JoinMeeting do
    subject { described_class.new(meeting, user, registration_form) }

    let(:registrations_enabled) { true }
    let(:registration_form) { nil }
    let(:available_slots) { 10 }
    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:process_admin) { create :process_admin, participatory_process: participatory_process }
    let(:component) { create :component, manifest_name: :meetings, participatory_space: participatory_process }
    let(:questionnaire) { nil }
    let(:meeting) { create :meeting, component: component, registrations_enabled: registrations_enabled, available_slots: available_slots, questionnaire: questionnaire }
    let(:user) { create :user, :confirmed, organization: organization, email_on_notification: false }

    let(:user_notification) do
      {
        event: "decidim.events.meetings.meeting_registration_confirmed",
        event_class: MeetingRegistrationNotificationEvent,
        resource: meeting,
        affected_users: [user],
        extra: { registration_code: kind_of(String) }
      }
    end

    let(:badge_earned) { hash_including(event: "decidim.events.gamification.badge_earned") }

    let(:admin_notification) do
      {
        event: "decidim.events.meetings.meeting_registrations_over_percentage",
        event_class: MeetingRegistrationsOverPercentageEvent,
        resource: meeting,
        recipient_ids: [process_admin.id],
        extra: extra
      }
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a registration for the meeting and the user" do
        expect { subject.call }.to change(Registration, :count).by(1)
        last_registration = Registration.last
        expect(last_registration.user).to eq(user)
        expect(last_registration.meeting).to eq(meeting)
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

      it "sends a notification to the user with the registration confirmed" do
        expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
        expect(Decidim::EventsManager).to receive(:publish).with(badge_earned)

        subject.call
      end

      it "increases the user's score" do
        expect { subject.call }.to change { Decidim::Gamification.status_for(user, :attended_meetings).score }.from(0).to(1)
      end

      context "and exists and invite for the user" do
        let!(:invite) { create(:invite, meeting: meeting, user: user) }

        it "marks the invite as accepted" do
          expect { subject.call }.to change { invite.reload.accepted_at }.from(nil).to(kind_of(Time))
        end
      end

      context "when the meeting available slots are occupied over the 50%" do
        let(:extra) { { percentage: 0.5 } }

        before do
          create_list :registration, (available_slots * 0.5).round - 1, meeting: meeting
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(badge_earned)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

          subject.call
        end

        context "when the 50% is already met" do
          before do
            create :registration, meeting: meeting
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
          create_list :registration, (available_slots * 0.8).round - 1, meeting: meeting
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(badge_earned)
          expect(Decidim::EventsManager).to receive(:publish).with(admin_notification)

          subject.call
        end

        context "when the 80% is already met" do
          before do
            create_list :registration, (available_slots * 0.8).round, meeting: meeting
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
          create_list :registration, available_slots - 1, meeting: meeting
        end

        it "also sends a notification to the process admins" do
          expect(Decidim::EventsManager).to receive(:publish).with(user_notification)
          expect(Decidim::EventsManager).to receive(:publish).with(badge_earned)
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
        create(:registration, meeting: meeting)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when there are a registration form" do
      let!(:questionnaire) { create(:questionnaire) }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0) }
      let(:meeting) { create :meeting, component: component, registrations_enabled: registrations_enabled, available_slots: available_slots, questionnaire: questionnaire }

      let(:valid) { true }
      let(:registration_form) do
        instance_double(
          Decidim::Forms::QuestionnaireForm,
          valid?: valid,
          invalid?: !valid,
          tos_agreement: true,
          answers: [
            double(
              question: question,
              body: "My answer response",
              selected_choices: []
            )
          ]
        )
      end

      context "and the registration form is invalid" do
        let(:valid) { false }

        it "broadcast invalid_form" do
          expect { subject.call }.to broadcast(:invalid_form)
        end
      end

      context "and everything is ok" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "saves the answers" do
          expect { subject.call }.to change(Decidim::Forms::Answer, :count).by(1)

          answer = Decidim::Forms::Answer.last
          expect(answer.user).to eq(user)
          expect(answer.body).to eq("My answer response")
        end
      end
    end
  end
end
