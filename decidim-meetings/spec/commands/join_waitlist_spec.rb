# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe JoinWaitlist do
    subject { described_class.new(meeting, form) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:component) { create(:component, manifest_name: :meetings, participatory_space: participatory_process) }
    let(:available_slots) { 2 }
    let(:meeting) do
      create(:meeting,
             component: component,
             registrations_enabled: true,
             available_slots: available_slots)
    end

    let(:user) { create(:user, :confirmed, organization: organization, notifications_sending_frequency: "none") }
    let(:form) do
      Decidim::Meetings::JoinMeetingForm.new.with_context(
        current_user: user
      )
    end

    let(:waitlist_notification) do
      {
        event: "decidim.events.meetings.meeting_waitlist_added",
        event_class: MeetingRegistrationNotificationEvent,
        resource: meeting,
        affected_users: [user]
      }
    end

    context "when all conditions are met" do
      before do
        create_list(:registration, available_slots, meeting: meeting, status: :registered)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a waitlist registration with correct attributes" do
        expect { subject.call }.to change(Registration, :count).by(1)
        last_registration = Registration.last
        expect(last_registration.user).to eq(user)
        expect(last_registration.meeting).to eq(meeting)
        expect(last_registration.status).to eq("waiting_list")
      end

      it "publishes waitlist notification" do
        expect(Decidim::EventsManager).to receive(:publish).with(waitlist_notification)
        subject.call
      end
    end

    context "when the user is already registered" do
      before do
        create(:registration, meeting: meeting, user: user, status: :registered)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when meeting has available slots" do
      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is invalid" do
      before do
        create_list(:registration, available_slots, meeting: meeting, status: :registered)
        allow(form).to receive(:valid?).and_return(false)
      end

      it "broadcasts invalid_form" do
        expect { subject.call }.to broadcast(:invalid_form)
      end
    end
  end
end
