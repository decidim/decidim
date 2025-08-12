# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe CopyMeeting do
        subject { described_class.new(form, meeting) }

        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:current_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
        let(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let(:meeting) { create(:meeting, :published, component: current_component, **meeting_attributes) }

        let(:meeting_attributes) do
          {
            registrations_enabled: true,
            available_slots: 50,
            registration_terms: { "en" => "Custom registration terms" },
            reserved_slots: 10,
            customize_registration_email: true,
            registration_form_enabled: true,
            registration_email_custom_content: { "en" => "Custom email content" }
          }
        end

        let(:form) do
          double(
            invalid?: false,
            current_user: user,
            current_organization: organization,
            taxonomies: [],
            title: { "en" => "Copied Meeting" },
            description: { "en" => "Copied description" },
            end_time: 2.hours.from_now,
            start_time: 1.hour.from_now,
            address: "Test Address",
            latitude: 40.1234,
            longitude: 2.1234,
            location: { "en" => "Test Location" },
            location_hints: { "en" => "Test hints" },
            private_meeting: false,
            transparent: true,
            questionnaire: nil,
            online_meeting_url: "https://example.com",
            type_of_meeting: "online",
            iframe_embed_type: "none",
            iframe_access_level: "signed_in",
            comments_enabled: true,
            comments_start_time: 1.hour.from_now,
            comments_end_time: 2.hours.from_now,
            registration_type: "on_this_platform",
            registration_url: nil,
            reminder_enabled: false,
            send_reminders_before_hours: 1,
            reminder_message_custom_content: nil,
            services_to_persist: []
          )
        end

        context "when form is valid" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "copies registration fields from original meeting" do
            subject.call
            copied_meeting = Meeting.last

            expect(copied_meeting.registrations_enabled).to eq(meeting.registrations_enabled)
            expect(copied_meeting.available_slots).to eq(meeting.available_slots)
            expect(copied_meeting.registration_terms).to eq(meeting.registration_terms)
            expect(copied_meeting.reserved_slots).to eq(meeting.reserved_slots)
            expect(copied_meeting.customize_registration_email).to eq(meeting.customize_registration_email)
            expect(copied_meeting.registration_form_enabled).to eq(meeting.registration_form_enabled)
            expect(copied_meeting.registration_email_custom_content).to eq(meeting.registration_email_custom_content)
          end

          it "creates a new meeting with form attributes" do
            subject.call
            copied_meeting = Meeting.last

            expect(copied_meeting.title).to eq(form.title)
            expect(copied_meeting.description).to eq(form.description)
            expect(copied_meeting.component).to eq(meeting.component)
            expect(copied_meeting.author).to eq(form.current_organization)
          end
        end
      end
    end
  end
end
