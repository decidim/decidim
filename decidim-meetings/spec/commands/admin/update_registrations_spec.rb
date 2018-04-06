# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateRegistrations do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting) }
    let(:invalid) { false }
    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:reserved_slots) { 2 }
    let(:registration_terms) do
      {
        en: "A legal text",
        es: "Un texto legal",
        ca: "Un text legal"
      }
    end
    let(:form) do
      double(
        invalid?: invalid,
        registrations_enabled: registrations_enabled,
        available_slots: available_slots,
        reserved_slots: reserved_slots,
        registration_terms: registration_terms
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "updates the meeting" do
        subject.call
        expect(meeting.registrations_enabled).to eq(registrations_enabled)
        expect(meeting.available_slots).to eq(available_slots)
        expect(meeting.reserved_slots).to eq(reserved_slots)
        expect(translated(meeting.registration_terms)).to eq "A legal text"
      end
    end

    describe "events" do
      let(:user) { create :user, :confirmed, organization: meeting.organization }
      let!(:follow) { create :follow, followable: meeting, user: user }

      context "when registrations are enabled" do
        it "notifies the change" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.meetings.registrations_enabled",
              event_class: MeetingRegistrationsEnabledEvent,
              resource: meeting,
              recipient_ids: [user.id]
            )

          subject.call
        end
      end

      context "when registrations are already enabled and something else changes" do
        let(:meeting) { create(:meeting, :with_registrations_enabled) }

        it "doesn't notify the change" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)

          subject.call
        end
      end
    end
  end
end
