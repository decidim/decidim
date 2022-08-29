# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::DestroyConferenceSpeaker, versioning: true do
    subject { described_class.new(conference_speaker, current_user) }

    let(:conference) { create(:conference) }
    let(:conference_speaker) { create :conference_speaker, conference: }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }

    context "when everything is ok" do
      let(:log_info) do
        {
          resource: {
            title: conference_speaker.full_name
          },
          participatory_space: {
            title: conference.title
          }
        }
      end

      it "destroys the conference member" do
        subject.call
        expect { conference_speaker.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", conference_speaker, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end
end
