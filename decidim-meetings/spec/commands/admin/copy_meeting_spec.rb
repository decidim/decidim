# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CopyMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create :meeting }

    let(:current_user) { create :user, :admin, :confirmed, organization: meeting.organization }
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
        scope: meeting.scope,
        category: meeting.category,
        services_to_persist:,
        current_user:,
        questionnaire: Decidim::Forms::Questionnaire.new,
        private_meeting: meeting.private_meeting,
        transparent: meeting.transparent,
        current_organization: current_user.organization,
        current_component: meeting.component
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
        expect { subject.call }.to change(Meeting, :count).by(2)

        old_meeting = Meeting.first
        new_meeting = Meeting.last

        expect(new_meeting.title["en"]).to eq("title")
        expect(new_meeting.description["en"]).to eq("description")
        expect(new_meeting.scope).to eq(old_meeting.scope)
        expect(new_meeting.category).to eq(old_meeting.category)
        expect(new_meeting.component).to eq(old_meeting.component)
        expect(new_meeting.component).not_to eq(be_published)

        new_meeting.services.each_with_index do |service, index|
          expect(service.title).to eq(services[index]["title"])
          expect(service.description).to eq(services[index]["description"])
        end
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end

    describe "events" do
      let!(:follow) { create :follow, followable: meeting.participatory_space, user: current_user }

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
