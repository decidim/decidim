# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::DestroyMeeting do
    subject { described_class.new(meeting, user) }

    let(:meeting) { create :meeting }
    let(:user) { create :user, :admin }

    context "when everything is ok" do
      it "destroys the meeting" do
        subject.call

        expect { meeting.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:delete, meeting, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
