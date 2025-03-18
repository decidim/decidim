# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CreateMeeting do
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
    let(:type_of_meeting) { "online" }
    let(:registration_url) { "http://decidim.org" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:iframe_embed_type) { "embed_in_meeting_page" }
    let(:iframe_access_level) { "all" }
    let(:registration_type) { "on_this_platform" }
    let(:registrations_enabled) { true }
    let(:available_slots) { 0 }
    let(:registration_terms) { Faker::Lorem.sentence(word_count: 3) }
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end
    let(:form) do
      double(
        invalid?: invalid,
        title: Faker::Lorem.sentence(word_count: 1),
        description: Faker::Lorem.sentence(word_count: 3),
        location: Faker::Lorem.sentence(word_count: 2),
        location_hints: Faker::Lorem.sentence(word_count: 3),
        start_time:,
        end_time: start_time + 2.hours,
        address:,
        latitude:,
        longitude:,
        current_user:,
        current_component:,
        component: current_component,
        current_organization: organization,
        registration_type:,
        available_slots:,
        registration_url:,
        registration_terms:,
        registrations_enabled:,
        clean_type_of_meeting: type_of_meeting,
        online_meeting_url:,
        iframe_embed_type:,
        iframe_access_level:,
        taxonomizations:
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

      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.meetings.create_meeting:before" do
        let(:command) { subject }
      end
      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.meetings.create_meeting:after" do
        let(:command) { subject }
      end

      it "creates and publishes the meeting and log both actions" do
        subject.call
        meeting.reload
        expect(meeting).to be_published
        expect { subject.call }.to change(Meeting, :count).by(1)
        expect { subject.call }.to change(Decidim::ActionLog, :count).by(2)
      end

      it "makes the user follow the meeting" do
        expect { subject.call }.to change(Decidim::Follow, :count).by(1)
        expect(meeting.reload.followers).to include(current_user)
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

      it "sets the registration_terms" do
        subject.call
        expect(meeting.registration_terms).to eq("en" => registration_terms)
      end

      it "sets the registrations_enabled flag" do
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

      it "is created as published" do
        subject.call

        expect(meeting).to be_published
      end

      it "sets iframe_embed_type" do
        subject.call

        expect(meeting.iframe_embed_type).to eq(iframe_embed_type)
      end

      context "when the author is a user" do
        it "sets the user as the author" do
          subject.call
          expect(meeting.author).to eq current_user
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Meeting, current_user, kind_of(Hash), visibility: "public-only")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "schedules a upcoming meeting notification job 48h before start time" do
        meeting = create(:meeting, start_time:, component: current_component, author: current_user)
        allow(Decidim.traceability)
          .to receive(:create!)
          .and_return(meeting)

        expect(meeting).to receive(:valid?)
        expect(meeting).to receive(:publish!)
        allow(meeting).to receive(:to_signed_global_id).and_return "gid://Decidim::Meetings::Meeting/#{meeting.id}"

        allow(UpcomingMeetingNotificationJob)
          .to receive(:generate_checksum).and_return "1234"

        expect(UpcomingMeetingNotificationJob)
          .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
          .with(set: start_time - Decidim::Meetings.upcoming_meeting_notification).with(meeting.id, "1234")

        allow(Decidim::EventsManager).to receive(:publish).and_return(true)

        subject.call
      end

      it "does not schedule an upcoming meeting notification if start time is in the past" do
        meeting = create(:meeting, start_time: 2.days.ago, component: current_component, author: current_user)
        allow(Decidim.traceability)
          .to receive(:create!)
          .and_return(meeting)

        expect(meeting).to receive(:valid?)
        expect(meeting).to receive(:publish!)
        allow(meeting).to receive(:to_signed_global_id).and_return "gid://Decidim::Meetings::Meeting/#{meeting.id}"

        expect(UpcomingMeetingNotificationJob).not_to receive(:generate_checksum)
        expect(UpcomingMeetingNotificationJob).not_to receive(:set)

        allow(Decidim::EventsManager).to receive(:publish).and_return(true)

        subject.call
      end

      it "sends a notification to the participatory space followers" do
        follower = create(:user, organization:)
        create(:follow, followable: participatory_process, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_created",
            event_class: Decidim::Meetings::CreateMeetingEvent,
            resource: kind_of(Meeting),
            followers: [follower]
          )

        subject.call
      end
    end
  end
end
