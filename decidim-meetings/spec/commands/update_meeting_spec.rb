# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe UpdateMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting) }
    let(:organization) { meeting.component.organization }
    let(:current_user) { create(:user, :confirmed, organization:) }
    let(:participatory_process) { meeting.component.participatory_space }
    let(:current_component) { meeting.component }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:type_of_meeting) { "online" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:registration_type) { "on_this_platform" }
    let(:available_slots) { 0 }
    let(:registration_url) { "http://decidim.org" }
    let(:iframe_embed_type) { "none" }
    let(:iframe_access_level) { nil }
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end
    let(:form) do
      double(
        invalid?: invalid,
        title: "The meeting title",
        description: "The meeting description text",
        location: "The meeting location text",
        location_hints: "The meeting location hint text",
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 1.hour,
        address:,
        latitude:,
        longitude:,
        current_user:,
        current_organization: organization,
        registration_type:,
        available_slots:,
        registration_url:,
        registration_terms: "The meeting registration terms",
        registrations_enabled: true,
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
      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.meetings.update_meeting:before" do
        let(:command) { subject }
      end

      it_behaves_like "fires an ActiveSupport::Notification event", "decidim.meetings.update_meeting:after" do
        let(:command) { subject }
      end

      it "updates the meeting" do
        subject.call

        expect(meeting.title).to include("en" => "The meeting title")
        expect(meeting.description).to include("en" => "The meeting description text")
      end

      it "sets the taxonomies" do
        subject.call
        expect(meeting.reload.taxonomies).to eq(taxonomizations.map(&:taxonomy))
      end

      it "sets the latitude and longitude" do
        subject.call
        expect(meeting.latitude).to eq(latitude)
        expect(meeting.longitude).to eq(longitude)
      end

      context "when the author is a user" do
        it "sets the user as the author" do
          subject.call
          expect(meeting.author).to eq current_user
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(meeting, current_user, kind_of(Hash), visibility: "public-only")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      describe "events" do
        let!(:follow) { create(:follow, followable: meeting, user: current_user) }
        let(:title) { meeting.title }
        let(:start_time) { meeting.start_time }
        let(:end_time) { meeting.end_time }
        let(:address) { meeting.address }
        let(:form) do
          double(
            invalid?: false,
            title:,
            description: meeting.description,
            location: meeting.location,
            location_hints: meeting.location_hints,
            start_time:,
            end_time:,
            taxonomizations: meeting.taxonomizations,
            address:,
            latitude: meeting.latitude,
            longitude: meeting.longitude,
            services_to_persist: [],
            current_user:,
            current_organization: organization,
            registration_type:,
            available_slots:,
            registration_url:,
            registration_terms: meeting.registration_terms,
            registrations_enabled: true,
            clean_type_of_meeting: type_of_meeting,
            online_meeting_url:,
            iframe_embed_type:,
            iframe_access_level:
          )
        end

        context "when nothing changes" do
          it "does not notify the change" do
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

          it "does not notify the change" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject.call
          end

          it "does not schedule the upcoming meeting notification job" do
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

          it_behaves_like "emits an upcoming notification" do
            let(:future_start_date) { 1.day.from_now + Decidim::Meetings.upcoming_meeting_notification }
            let(:past_start_date) { 1.day.ago }
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
