# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe JoinMeeting do
    subject { described_class.new(meeting, user, registration_form) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:process_admin) { create :process_admin, participatory_process: participatory_process }
    let(:component) { create :component, manifest_name: :meetings, participatory_space: participatory_process }
    let(:meeting) { create :meeting, component: component, registrations_enabled: registrations_enabled, available_slots: available_slots }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:registration_form) { nil }

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

      context "and meeting have a registration form" do
        let(:questionnaire) { create(:questionnaire, meeting: meeting, questionnaire_type: "registration") }
        let(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "short_answer", position: 0) }

        context "and the form is invalid" do
          let(:registration_form) do
            QuestionnaireForm.from_params({})
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "and the form is valid" do
          let(:registration_form) do
            QuestionnaireForm.from_params(
              "questionnaire" => { "questionnaire_answers" => [{ "body" => "This is my first answer", "question_id" => questionnaire_question.id }], "tos_agreement" => "1" }
            )
          end

          it "saves the answers to the questionnaire" do
            expect { subject.call }.to change(QuestionnaireAnswer, :count).by(1)
            last_answer = QuestionnaireAnswer.last
            expect(last_answer.user).to eq(user)
            expect(last_answer.question).to eq(questionnaire_question)
            expect(last_answer.questionnaire).to eq(questionnaire)
          end
        end
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
              event_class: MeetingRegistrationsOverPercentageEvent,
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
              event_class: MeetingRegistrationsOverPercentageEvent,
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
              event_class: MeetingRegistrationsOverPercentageEvent,
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
end
