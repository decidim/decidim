# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe LeaveMeeting do
    subject { described_class.new(meeting, user_leaving_meeting) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:meeting) { create :meeting, registrations_enabled:, available_slots: }
    let(:user) { create :user, :confirmed, organization: meeting.organization }
    let(:user_leaving_meeting) { user }

    before do
      create(:registration, meeting:, user:)
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "decreases the user's score" do
        Decidim::Gamification.set_score(user, :attended_meetings, 1)
        expect { subject.call }.to change { Decidim::Gamification.status_for(user, :attended_meetings).score }.from(1).to(0)
      end

      it "destroys the registration for the meeting and the user" do
        expect { subject.call }.to change(Registration, :count).by(-1)
      end

      context "when the questionnaire/registration form is missing" do
        before do
          meeting.questionnaire.destroy
        end

        it "allows the user to leave successully" do
          expect { subject.call }.to broadcast(:ok)
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
