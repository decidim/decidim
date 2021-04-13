# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe PublishMeeting do
        subject { described_class.new(meeting, user) }

        let(:meeting) { create :meeting }
        let(:user) { create :user, :admin, :confirmed, organization: meeting.organization }

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
        end
      end
    end
  end
end
