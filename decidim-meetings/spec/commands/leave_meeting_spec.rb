# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe LeaveMeeting do
    subject { described_class.new(meeting, user_leaving_meeting) }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:meeting) { create(:meeting, registrations_enabled:, available_slots:) }
    let(:user) { create(:user, :confirmed, organization: meeting.organization) }
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

        it "allows the user to leave successfully" do
          expect { subject.call }.to broadcast(:ok)
        end
      end
    end

    context "when the user has not joined the meeting" do
      let(:user_leaving_meeting) { create(:user, :confirmed, organization: meeting.organization) }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when a user is on the waitlist and a slot becomes free" do
      let(:user_on_waitlist) { create(:user, :confirmed, organization: meeting.organization) }

      before do
        create(:registration, meeting:, user: user_on_waitlist, status: :waiting_list)
        clear_enqueued_jobs
      end

      it "promotes the user on waitlist" do
        expect do
          perform_enqueued_jobs { subject.call }
        end.to change { meeting.registrations.waiting_list.count }.by(-1)

        expect do
          perform_enqueued_jobs { subject.call }
        end.not_to(change { meeting.registrations.registered.count })

        promoted = meeting.registrations.find_by(user: user_on_waitlist)
        expect(promoted.status).to eq("registered")
      end
    end

    context "when there are no remaining slots" do
      before do
        allow(meeting).to receive(:remaining_slots).and_return(0)
      end

      it "does not enqueue PromoteFromWaitlistJob" do
        expect(PromoteFromWaitlistJob).not_to receive(:perform_later)
        subject.call
      end
    end

    context "when available_slots is unlimited (0)" do
      let(:available_slots) { 0 }

      before do
        create(:registration, meeting:, user: create(:user, :confirmed, organization: meeting.organization), status: :waiting_list)
      end

      it "does not enqueue PromoteFromWaitlistJob" do
        expect(PromoteFromWaitlistJob).not_to receive(:perform_later)
        subject.call
      end
    end

    context "when there are no users on the waitlist" do
      it "does not enqueue PromoteFromWaitlistJob" do
        expect(PromoteFromWaitlistJob).not_to receive(:perform_later)
        subject.call
      end
    end
  end
end
