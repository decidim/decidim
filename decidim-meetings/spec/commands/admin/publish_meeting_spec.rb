# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe PublishMeeting do
        subject { described_class.new(meeting, user) }

        let(:organization) { create :organization, available_locales: [:en] }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:participatory_process) { create :participatory_process, organization: organization }
        let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
        let(:meeting) { create :meeting, component: current_component }

        context "when the meeting is already published" do
          let(:meeting) { create :meeting, :published }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "publishes the meeting" do
            subject.call
            meeting.reload
            expect(meeting).to be_published
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:publish, meeting, user, visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "schedules a upcoming meeting notification job 48h before start time" do
            expect(UpcomingMeetingNotificationJob)
              .to receive(:generate_checksum).and_return "1234"

            expect(UpcomingMeetingNotificationJob)
              .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
              .with(set: meeting.start_time - 2.days)
              .with(kind_of(Integer), "1234")

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
  end
end
