# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::DestroyMeeting do
    subject { described_class.new(meeting, user) }

    let(:meeting) { create :meeting, component: meeting_component }
    let(:user) { create :user, :admin, organization: organization }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
    let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:proposal) { create(:proposal, component: proposal_component) }
    let(:meeting_proposals) { meeting.authored_proposals }

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

    context "when the meeting has at least one proposal associated to it" do
      before do
        proposal.coauthorships.clear
        proposal.add_coauthor(meeting)
      end

      it "broadcasts invalid and proposals count" do
        expect do
          subject.call
        end.to broadcast(:invalid, meeting_proposals.size)
      end

      it "cannot destroy the meeting" do
        subject.call

        expect { meeting.reload }.not_to raise_error
      end
    end
  end
end
