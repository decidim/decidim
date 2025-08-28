# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CreateMeeting do
    subject { described_class.new(form) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "meetings") }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:transparent_type) { "transparent" }
    let(:type_of_meeting) { "online" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:registration_url) { "http://decidim.org" }
    let(:registration_type) { "on_this_platform" }
    let(:registrations_enabled) { true }
    let(:iframe_embed_type) { "embed_in_meeting_page" }
    let(:iframe_access_level) { "all" }
    let(:reminder_enabled) { true }
    let(:send_reminders_before_hours) { 50 }
    let(:reminder_message_custom_content) { { "en" => "Custom reminder message", "es" => "Mensaje de recordatorio personalizado", "ca" => "Missatge de recordatori personalitzat" } }
    let(:components) { [] }
    let(:services) do
      [
        {
          "title" => { "en" => "First service" },
          "description" => { "en" => "First description" }
        },
        {
          "title" => { "en" => "Second service" },
          "description" => { "en" => "Second description" }
        }
      ]
    end
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end
    let(:services_to_persist) do
      services.map { |service| Admin::MeetingServiceForm.from_params(service) }
    end

    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        location: { en: "location" },
        location_hints: { en: "location_hints" },
        start_time:,
        end_time: 1.day.from_now + 1.hour,
        address:,
        latitude:,
        longitude:,
        taxonomizations:,
        private_meeting:,
        transparent:,
        services_to_persist:,
        current_user:,
        current_component:,
        component: current_component,
        current_organization: organization,
        registration_type:,
        registration_url:,
        registrations_enabled:,
        clean_type_of_meeting: type_of_meeting,
        online_meeting_url:,
        iframe_embed_type:,
        comments_enabled: true,
        comments_start_time: nil,
        comments_end_time: nil,
        iframe_access_level:,
        components:,
        reminder_enabled:,
        send_reminders_before_hours:,
        reminder_message_custom_content:
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:meeting) { Meeting.last }

      it "creates the meeting" do
        expect { subject.call }.to change(Meeting, :count).by(1)
      end

      it "sets the taxonomies" do
        subject.call
        expect(meeting.taxonomizations).to match_array(taxonomizations)
      end

      context "when no taxonomizations are set" do
        let(:taxonomizations) { [] }

        it "taxonomizations are empty" do
          subject.call

          expect(meeting.taxonomizations).to be_empty
        end
      end

      it "sets the reminder message" do
        subject.call
        expect(meeting.reminder_message_custom_content).to eq(reminder_message_custom_content)
      end

      it "sets the send_reminders_before_hours" do
        subject.call
        expect(meeting.send_reminders_before_hours).to eq(send_reminders_before_hours)
        expect(meeting.reminder_message_custom_content).to eq(reminder_message_custom_content)
      end

      context "when reminder is not enabled" do
        let(:reminder_enabled) { false }

        it "sends reminders before hours is nil" do
          subject.call
          expect(meeting.send_reminders_before_hours).to be_nil
          expect(meeting.reminder_message_custom_content).to be_empty
        end
      end

      it "sets the author" do
        subject.call
        expect(meeting.author).to eq organization
      end

      it "sets the registration enabled flag" do
        subject.call
        expect(meeting.registrations_enabled).to eq registrations_enabled
      end

      it "sets the component" do
        subject.call
        expect(meeting.component).to eq current_component
      end

      it "sets the longitude and latitude" do
        subject.call
        last_meeting = Meeting.last
        expect(last_meeting.latitude).to eq(latitude)
        expect(last_meeting.longitude).to eq(longitude)
      end

      it "sets the services" do
        subject.call

        meeting.services.each_with_index do |service, index|
          expect(service.title).to eq(services[index]["title"])
          expect(service.description).to eq(services[index]["description"])
        end
      end

      it "sets the questionnaire for registrations" do
        subject.call
        expect(meeting.questionnaire).to be_a(Decidim::Forms::Questionnaire)
      end

      it "is created as unpublished" do
        subject.call

        expect(meeting).not_to be_published
      end

      it "makes the user follow the meeting" do
        expect { subject.call }.to change(Decidim::Follow, :count).by(1)
        expect(meeting.reload.followers).to include(current_user)
      end

      it "sets iframe_embed_type" do
        subject.call

        expect(meeting.iframe_embed_type).to eq(iframe_embed_type)
      end

      it "sets iframe_access_level" do
        subject.call

        expect(meeting.iframe_access_level).to eq(iframe_access_level)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Meeting, current_user, kind_of(Hash), visibility: "all")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
