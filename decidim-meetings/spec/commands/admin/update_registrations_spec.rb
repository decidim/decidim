# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateRegistrations do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting) }
    let(:invalid) { false }
    let(:registrations_enabled) { true }
    let(:registration_form_enabled) { true }
    let(:available_slots) { 10 }
    let(:reserved_slots) { 2 }
    let(:customize_registration_email) { true }
    let(:registration_email_custom_content) { { "en" => "The registration email custom content." } }
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
        registrations_enabled:,
        registration_form_enabled:,
        available_slots:,
        reserved_slots:,
        customize_registration_email:,
        registration_email_custom_content:,
        registration_terms:,
        current_user: meeting.author
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
        expect(meeting.registration_form_enabled).to eq(registration_form_enabled)
        expect(meeting.available_slots).to eq(available_slots)
        expect(meeting.reserved_slots).to eq(reserved_slots)
        expect(meeting.customize_registration_email).to be true
        expect(meeting.registration_email_custom_content).to eq(registration_email_custom_content)
        expect(translated(meeting.registration_terms)).to eq "A legal text"
      end
    end

    describe "events" do
      let(:user) { create(:user, :confirmed, organization: meeting.organization) }
      let!(:follow) { create(:follow, followable: meeting, user:) }

      context "when registrations are enabled" do
        it "notifies the change" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.meetings.registrations_enabled",
              event_class: MeetingRegistrationsEnabledEvent,
              resource: meeting,
              followers: [user]
            )

          subject.call
        end
      end

      context "when registrations are already enabled and something else changes" do
        let(:meeting) { create(:meeting, :with_registrations_enabled) }

        it "does not notify the change" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)

          subject.call
        end
      end
    end

    describe "waitlist promotion" do
      let!(:meeting) { create(:meeting, :with_registrations_enabled) }

      let(:form) do
        double(
          invalid?: false,
          registrations_enabled: true,
          registration_form_enabled: false,
          available_slots: new_available_slots,
          reserved_slots: new_reserved_slots,
          customize_registration_email: false,
          registration_email_custom_content: {},
          registration_terms: { en: "Legal text" },
          current_user: meeting.author
        )
      end

      before do
        clear_enqueued_jobs
      end

      context "when a slot becomes available and a user is on the waitlist" do
        let(:new_available_slots) { 12 }
        let(:new_reserved_slots) { 4 }

        let!(:registered_users) { create_list(:registration, 6, meeting:, status: :registered) }
        let!(:registration_on_waitlist) { create(:registration, meeting:, status: :waiting_list) }

        it "promotes the user on waitlist to registered" do
          described_class.new(form, meeting).call
          perform_enqueued_jobs

          promoted = meeting.registrations.find_by(user: registration_on_waitlist.user)
          expect(promoted.status).to eq("registered")
          expect(meeting.registrations.registered.count).to eq(7)
        end
      end

      context "when available_slots did not change" do
        let(:new_available_slots) { meeting.available_slots }
        let(:new_reserved_slots) { meeting.reserved_slots }

        before do
          create_list(:registration, 6, meeting:, status: :registered)
          create(:registration, meeting:, status: :waiting_list)
        end

        it "does not promote any user on waitlist" do
          expect do
            described_class.new(form, meeting).call
            perform_enqueued_jobs
          end.not_to(change { meeting.registrations.registered.count })
        end
      end

      context "when no users are on the waitlist" do
        let(:new_available_slots) { 12 }
        let(:new_reserved_slots) { 4 }

        before do
          create_list(:registration, 6, meeting:, status: :registered)
        end

        it "does not promote anyone" do
          expect do
            described_class.new(form, meeting).call
            perform_enqueued_jobs
          end.not_to(change { meeting.registrations.registered.count })
        end
      end

      context "when available_slots is set to unlimited (0)" do
        let(:new_available_slots) { 0 }
        let(:new_reserved_slots) { 0 }

        before do
          create(:registration, meeting:, status: :waiting_list)
        end

        it "does not promote anyone from waitlist" do
          expect do
            described_class.new(form, meeting).call
            perform_enqueued_jobs
          end.not_to(change { meeting.registrations.registered.count })
        end
      end
    end
  end
end
