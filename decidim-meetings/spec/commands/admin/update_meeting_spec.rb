# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting, :published) }
    let(:organization) { meeting.component.organization }
    let(:address) { meeting.address }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:service_objects) { build_list(:service, 2) }
    let(:services) do
      service_objects.map(&:attributes)
    end
    let(:services_to_persist) do
      services.map { |service| Admin::MeetingServiceForm.from_params(service) }
    end
    let(:user) { create(:user, :admin, organization:) }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:type_of_meeting) { "online" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:registration_url) { "http://decidim.org" }
    let(:registration_type) { "on_this_platform" }
    let(:registrations_enabled) { true }
    let(:iframe_embed_type) { "none" }
    let(:iframe_access_level) { nil }
    let(:components) { [] }
    let(:taxonomizations) do
      2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
    end

    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        location: { en: "location" },
        location_hints: { en: "location_hints" },
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 1.hour,
        taxonomizations:,
        address:,
        latitude:,
        longitude:,
        private_meeting:,
        transparent:,
        services_to_persist:,
        current_user: user,
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
        components:
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
        expect(translated(meeting.title)).to eq "title"
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

      it "sets the author" do
        subject.call
        expect(meeting.author).to eq organization
      end

      it "sets the registration enabled flag" do
        subject.call
        expect(meeting.registrations_enabled).to eq registrations_enabled
      end

      it "sets the services" do
        subject.call
        meeting.services.each_with_index do |service, index|
          expect(service.title).to eq(service_objects[index].title)
          expect(service.description).to eq(service_objects[index].description)
        end
      end

      it "sets iframe_access_level" do
        subject.call

        expect(meeting.iframe_access_level).to eq(iframe_access_level)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(meeting, user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      describe "events" do
        let!(:follow) { create(:follow, followable: meeting, user:) }
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
            private_meeting:,
            transparent:,
            services_to_persist:,
            current_user: user,
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
            components:
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
                followers: [user],
                extra: { changed_fields: %w(start_time) }
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
                followers: [user],
                extra: { changed_fields: %w(end_time) }
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
                followers: [user],
                extra: { changed_fields: %w(address) }
              )

            subject.call
          end
        end

        context "when the meeting is unpublished" do
          let(:meeting) { create(:meeting) }

          context "when the start time changes" do
            let(:start_time) { meeting.start_time - 1.day }

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
        end
      end
    end
  end
end
