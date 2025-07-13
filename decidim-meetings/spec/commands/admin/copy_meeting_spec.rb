# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CopyMeeting do
    subject { described_class.new(form, meeting) }

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:meeting_component, participatory_space:) }
    let!(:meeting) { create(:meeting, component:, taxonomies: [taxonomy]) }

    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:services) do
      build_list(:service, 2, meeting:)
    end
    let(:services_to_persist) do
      services.map { |service| Admin::MeetingServiceForm.from_params(service.attributes) }
    end
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }

    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        location: { en: "location" },
        location_hints: { en: "location hints" },
        start_time:,
        end_time: 1.day.from_now + 1.hour,
        address:,
        latitude:,
        longitude:,
        reminder_enabled: meeting.reminder_enabled,
        send_reminders_before_hours: meeting.send_reminders_before_hours,
        reminder_message_custom_content: meeting.reminder_message_custom_content,
        taxonomies: meeting.taxonomies,
        services_to_persist:,
        current_user:,
        questionnaire: Decidim::Forms::Questionnaire.new,
        private_meeting: meeting.private_meeting,
        transparent: meeting.transparent,
        current_organization: organization,
        current_component: meeting.component,
        online_meeting_url: meeting.online_meeting_url,
        iframe_embed_type: meeting.iframe_embed_type,
        iframe_access_level: meeting.iframe_access_level,
        comments_enabled: meeting.comments_enabled,
        comments_start_time: meeting.comments_start_time,
        comments_end_time: meeting.comments_end_time,
        registration_type: :on_this_platform,
        registration_url: meeting.registration_url,
        type_of_meeting: meeting.type_of_meeting
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "duplicates a meeting" do
        expect { subject.call }.to change(Meeting, :count).by(1)

        old_meeting = meeting
        new_meeting = Meeting.last

        expect(new_meeting.title["en"]).to eq("title")
        expect(new_meeting.description["en"]).to eq("description")
        expect(new_meeting.taxonomies).to eq(old_meeting.taxonomies)
        expect(new_meeting.component).to eq(old_meeting.component)
        expect(new_meeting.component).not_to eq(be_published)
        expect(new_meeting.reminder_message_custom_content).to eq(old_meeting.reminder_message_custom_content)

        new_meeting.services.each_with_index do |service, index|
          expect(service.title).to eq(services[index]["title"])
          expect(service.description).to eq(services[index]["description"])
        end
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      context "and saves the correct meeting type" do
        context "with in_person meeting type" do
          let!(:meeting) { create(:meeting, :in_person, component:) }

          it "duplicates an in_person meeting" do
            expect { subject.call }.to change(Meeting, :count).by(1)
            new_meeting = Meeting.last
            expect(new_meeting.type_of_meeting).to eq(meeting.type_of_meeting)
          end
        end

        context "with online meeting type" do
          let!(:meeting) { create(:meeting, :online, component:) }

          it "duplicates an online meeting" do
            expect { subject.call }.to change(Meeting, :count).by(1)
            new_meeting = Meeting.last
            expect(new_meeting.type_of_meeting).to eq(meeting.type_of_meeting)
            expect(new_meeting.online_meeting_url).to eq(meeting.online_meeting_url)
          end
        end

        context "with hybrid meeting type" do
          let!(:meeting) { create(:meeting, :hybrid, component:) }

          it "duplicates a hybrid meeting" do
            expect { subject.call }.to change(Meeting, :count).by(1)
            new_meeting = Meeting.last
            expect(new_meeting.type_of_meeting).to eq(meeting.type_of_meeting)
            expect(new_meeting.online_meeting_url).to eq(meeting.online_meeting_url)
          end
        end
      end
    end

    describe "events" do
      let!(:follow) { create(:follow, followable: meeting.participatory_space, user: current_user) }

      it "notifies the change" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_created",
            event_class: CreateMeetingEvent,
            resource: kind_of(Decidim::Meetings::Meeting),
            followers: [current_user]
          )

        subject.call
      end
    end
  end
end
