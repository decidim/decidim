# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting) }
    let(:organization) { meeting.component.organization }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: meeting.component.participatory_space }
    let(:address) { meeting.address }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
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
    let(:services_to_persist) do
      services.map { |service| Admin::MeetingServiceForm.from_params(service) }
    end
    let(:user) { create :user, :admin, organization: organization }
    let(:organizer) { organization }
    let(:private_meeting) { false }
    let(:transparent) { true }
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
        organizer: organizer,
        organizer_id: organizer.id,
        organizer_type: organizer.class.name,
        private_meeting: private_meeting,
        transparent: transparent,
        services_to_persist: services_to_persist,
        current_user: user,
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

      it "sets the organizer" do
        subject.call
        expect(meeting.organizer).to eq organizer
      end

      it "sets the services" do
        subject.call
        expect(meeting.services).to eq(services)
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
            organizer: organizer,
            private_meeting: private_meeting,
            transparent: transparent,
            services_to_persist: services_to_persist,
            current_user: user,
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
                followers: [user]
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
      end
    end
  end
end
