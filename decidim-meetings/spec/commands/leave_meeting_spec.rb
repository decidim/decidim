# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe LeaveMeeting do
    subject { described_class.new(meeting, user_leaving_meeting) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:meeting) { create :meeting, registrations_enabled: registrations_enabled, available_slots: available_slots }
    let(:user) { create :user, :confirmed, organization: meeting.organization }
    let(:user_leaving_meeting) { user }

    before do
      create(:registration, meeting: meeting, user: user)
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "destroys the registration for the meeting and the user" do
        expect { subject.call }.to change(Registration, :count).by(-1)
      end

      context "and meeting has a registration form" do
        let(:questionnaire) { create(:questionnaire, meeting: meeting, questionnaire_type: "registration") }
        let(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0) }

        before do
          create(:questionnaire_answer, questionnaire: questionnaire, question: questionnaire_question, user: user)
        end

        it "destroy the registration form for the meeting and the user" do
          expect { subject.call }.to change(QuestionnaireAnswer, :count).by(-1)
        end
      end
    end

    context "when the user has not joined the meeting" do
      let(:user_leaving_meeting) { create :user, :confirmed, organization: meeting.organization }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
