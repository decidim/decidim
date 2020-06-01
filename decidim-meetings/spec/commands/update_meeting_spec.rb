# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe UpdateMeeting do
    subject { described_class.new(form, current_user, meeting) }

    let(:meeting) { create :meeting }
    let(:organization) { meeting.component.organization }
    let(:current_user) { create :user, :confirmed, organization: organization }
    let(:participatory_process) { meeting.component.participatory_space }
    let(:current_component) { meeting.component }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:organizer) { create :user, organization: organization }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:transparent_type) { "transparent" }
    let(:form) do
      double(
        invalid?: invalid,
        title: "The meeting title",
        description: "The meeting description text",
        location: "The meeting location text",
        location_hints: "The meeting location hint text",
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 1.hour,
        scope: scope,
        category: category,
        address: address,
        latitude: latitude,
        longitude: longitude,
        organizer: organizer,
        private_meeting: private_meeting,
        transparent: transparent,
        current_user: current_user,
        current_organization: organization
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the meeting" do
        subject.call

        expect(meeting.title).to eq "The meeting title"
        expect(meeting.description).to eq "The meeting description text"
      end

      it "sets the scope" do
        subject.call
        expect(meeting.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(meeting.category).to eq category
      end

      it "sets the latitude and longitude" do
        subject.call
        expect(meeting.latitude).to eq(latitude)
        expect(meeting.longitude).to eq(longitude)
      end

      context "when the organizer is a user_group" do
        let(:organizer) { create :user_group, users: [current_user], organization: organization }

        it "sets the user_group as the organizer" do
          subject.call
          expect(meeting.organizer).to eq organizer
        end
      end

      context "when the organizer is a user" do
        it "sets the user as the organizer" do
          subject.call
          expect(meeting.organizer).to eq organizer
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(meeting, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      describe "events" do
        let!(:follow) { create :follow, followable: meeting, user: current_user }
        let(:title) { meeting.title }
        let(:start_time) { meeting.start_time }
        let(:end_time) { meeting.end_time }
        let(:address) { meeting.address }
        let(:form) do
          double(
            invalid?: false,
            title: title,
            description: meeting.description,
            location: meeting.location,
            location_hints: meeting.location_hints,
            start_time: start_time,
            end_time: end_time,
            scope: meeting.scope,
            category: meeting.category,
            address: address,
            latitude: meeting.latitude,
            longitude: meeting.longitude,
            organizer: organizer,
            private_meeting: private_meeting,
            transparent: transparent,
            services_to_persist: [],
            current_user: current_user,
            current_organization: organization
          )
        end

        context "when nothing changes" do
          it "doesn't notify the change" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.call
          end
        end

        context "when a non-important attribute changes" do
          let(:title) do
            {
              "en" => "Title updated"
            }
          end

          it "doesn't notify the change" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.call
          end

          it "doesn't schedule the upcoming meeting notification job" do
            expect(UpcomingMeetingNotificationJob)
              .not_to receive(:perform_later)

            subject.call
          end
        end

        context "when the start time changes" do
          let(:start_time) { meeting.start_time - 1.day }

          it "notifies the change" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.meetings.meeting_updated",
                event_class: UpdateMeetingEvent,
                resource: meeting,
                followers: [current_user]
              )

            subject.call
          end

          it "schedules a upcoming meeting notification job 48h before start time" do
            expect(UpcomingMeetingNotificationJob)
              .to receive(:generate_checksum).and_return "1234"

            expect(UpcomingMeetingNotificationJob)
              .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
              .with(set: start_time - 2.days).with(meeting.id, "1234")

            subject.call
          end
        end

        context "when the end time changes" do
          let(:end_time) { meeting.start_time + 1.day }

          it "notifies the change" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.meetings.meeting_updated",
                event_class: UpdateMeetingEvent,
                resource: meeting,
                followers: [current_user]
              )

            subject.call
          end
        end

        context "when the address changes" do
          let(:address) { "some address" }

          it "notifies the change" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.meetings.meeting_updated",
                event_class: UpdateMeetingEvent,
                resource: meeting,
                followers: [current_user]
              )

            subject.call
          end
        end
      end
    end
  end
end
