# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting, :published) }
    let(:organization) { meeting.component.organization }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: meeting.component.participatory_space }
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
    let(:user) { create :user, :admin, organization: organization }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:type_of_meeting) { "online" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:registration_url) { "http://decidim.org" }
    let(:registration_type) { "on_this_platform" }
    let(:available_slots) { 0 }
    let(:customize_registration_email) { true }
    let(:registration_email_custom_content) { { "en" => "The registration email custom content." } }
    let(:iframe_embed_type) { "none" }
    let(:iframe_access_level) { nil }

    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        location: { en: "location" },
        location_hints: { en: "location_hints" },
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 1.hour,
        scope: scope,
        category: category,
        address: address,
        latitude: latitude,
        longitude: longitude,
        private_meeting: private_meeting,
        transparent: transparent,
        services_to_persist: services_to_persist,
        current_user: user,
        current_organization: organization,
        registration_type: registration_type,
        available_slots: available_slots,
        registration_url: registration_url,
        clean_type_of_meeting: type_of_meeting,
        online_meeting_url: online_meeting_url,
        customize_registration_email: customize_registration_email,
        registration_email_custom_content: registration_email_custom_content,
        iframe_embed_type: iframe_embed_type,
        comments_enabled: true,
        comments_start_time: nil,
        comments_end_time: nil,
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
      it "updates the meeting" do
        subject.call
        expect(translated(meeting.title)).to eq "title"
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

      it "sets the author" do
        subject.call
        expect(meeting.author).to eq organization
      end

      it "sets the services" do
        subject.call
        meeting.services.each_with_index do |service, index|
          expect(service.title).to eq(service_objects[index].title)
          expect(service.description).to eq(service_objects[index].description)
        end
      end

      it "sets the registration email related fields" do
        subject.call

        expect(meeting.customize_registration_email).to be true
        expect(meeting.registration_email_custom_content).to eq(registration_email_custom_content)
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
        let!(:follow) { create :follow, followable: meeting, user: user }
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
            private_meeting: private_meeting,
            transparent: transparent,
            services_to_persist: services_to_persist,
            current_user: user,
            current_organization: organization,
            registration_type: registration_type,
            available_slots: available_slots,
            registration_url: registration_url,
            clean_type_of_meeting: type_of_meeting,
            online_meeting_url: online_meeting_url,
            customize_registration_email: customize_registration_email,
            registration_email_custom_content: registration_email_custom_content,
            iframe_embed_type: iframe_embed_type,
            comments_enabled: true,
            comments_start_time: nil,
            comments_end_time: nil,
            iframe_access_level: iframe_access_level
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
                followers: [user]
              )

            subject.call
          end

          context "when future meeting" do
            let(:start_time) { meeting.start_time + 1.day }

            it "schedules a upcoming meeting notification job 48h before start time" do
              expect(UpcomingMeetingNotificationJob)
                .to receive(:generate_checksum).and_return "1234"

              expect(UpcomingMeetingNotificationJob)
                .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
                .with(set: start_time - Decidim::Meetings.upcoming_meeting_notification).with(meeting.id, "1234")

              subject.call
            end
          end

          context "when past meeting" do
            let(:start_time) { meeting.start_time - Decidim::Meetings.upcoming_meeting_notification }

            it "schedules a upcoming meeting notification job 48h before start time" do
              expect(UpcomingMeetingNotificationJob).not_to receive(:generate_checksum)

              expect(UpcomingMeetingNotificationJob).not_to receive(:set)
              expect(UpcomingMeetingNotificationJob).not_to receive(:perform_later)

              subject.call
            end
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
                followers: [user]
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
                followers: [user]
              )

            subject.call
          end
        end

        context "when the meeting is unpublished" do
          let(:meeting) { create(:meeting) }

          context "when the start time changes" do
            let(:start_time) { meeting.start_time - 1.day }

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
        end
      end
    end
  end
end
