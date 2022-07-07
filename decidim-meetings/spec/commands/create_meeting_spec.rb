# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CreateMeeting do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:user_group_id) { nil }
    let(:type_of_meeting) { "online" }
    let(:registration_url) { "http://decidim.org" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:iframe_embed_type) { "embed_in_meeting_page" }
    let(:iframe_access_level) { "all" }
    let(:registration_type) { "on_this_platform" }
    let(:registrations_enabled) { true }
    let(:available_slots) { 0 }
    let(:registration_terms) { Faker::Lorem.sentence(word_count: 3) }
    let(:form) do
      double(
        invalid?: invalid,
        title: Faker::Lorem.sentence(word_count: 1),
        description: Faker::Lorem.sentence(word_count: 3),
        location: Faker::Lorem.sentence(word_count: 2),
        location_hints: Faker::Lorem.sentence(word_count: 3),
        start_time: start_time,
        end_time: start_time + 2.hours,
        address: address,
        latitude: latitude,
        longitude: longitude,
        scope: scope,
        category: category,
        user_group_id: user_group_id,
        current_user: current_user,
        current_component: current_component,
        current_organization: organization,
        registration_type: registration_type,
        available_slots: available_slots,
        registration_url: registration_url,
        registration_terms: registration_terms,
        registrations_enabled: registrations_enabled,
        clean_type_of_meeting: type_of_meeting,
        online_meeting_url: online_meeting_url,
        iframe_embed_type: iframe_embed_type,
        iframe_access_level: iframe_access_level
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

      it "sets the scope" do
        subject.call
        expect(meeting.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(meeting.category).to eq category
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

      context "when the author is a user_group" do
        let(:user_group) { create :user_group, :verified, users: [current_user], organization: organization }
        let(:user_group_id) { user_group.id }

        it "sets the user_group as the author" do
          subject.call
          expect(meeting.author).to eq current_user
          expect(meeting.normalized_author).to eq user_group
        end
      end

      context "when the author is a user" do
        it "sets the user as the author" do
          subject.call
          expect(meeting.author).to eq current_user
          expect(meeting.normalized_author).to eq current_user
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
        meeting = instance_double(Meeting, id: 1, start_time: start_time, participatory_space: participatory_process)
        allow(Decidim.traceability)
          .to receive(:create!)
          .and_return(meeting)

        expect(meeting).to receive(:valid?)
        expect(meeting).to receive(:publish!)
        allow(meeting).to receive(:to_signed_global_id).and_return "gid://Decidim::Meetings::Meeting/1"

        allow(UpcomingMeetingNotificationJob)
          .to receive(:generate_checksum).and_return "1234"

        expect(UpcomingMeetingNotificationJob)
          .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
          .with(set: start_time - Decidim::Meetings.upcoming_meeting_notification).with(1, "1234")

        allow(Decidim::EventsManager).to receive(:publish).and_return(true)

        subject.call
      end

      it "doesn't schedule an upcoming meeting notification if start time is in the past" do
        meeting = instance_double(Meeting, id: 1, start_time: 2.days.ago, participatory_space: participatory_process)
        allow(Decidim.traceability)
          .to receive(:create!)
          .and_return(meeting)

        expect(meeting).to receive(:valid?)
        expect(meeting).to receive(:publish!)
        allow(meeting).to receive(:to_signed_global_id).and_return "gid://Decidim::Meetings::Meeting/1"

        expect(UpcomingMeetingNotificationJob).not_to receive(:generate_checksum)
        expect(UpcomingMeetingNotificationJob).not_to receive(:set)

        allow(Decidim::EventsManager).to receive(:publish).and_return(true)

        subject.call
      end

      it "sends a notification to the participatory space followers" do
        follower = create(:user, organization: organization)
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
