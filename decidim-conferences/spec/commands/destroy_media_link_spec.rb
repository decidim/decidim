# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::DestroyMediaLink, versioning: true do
    subject { described_class.new(media_link, current_user) }

    let(:conference) { create(:conference) }
    let(:media_link) { create :media_link, conference: }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }

    context "when everything is ok" do
      let(:log_info) do
        {
          resource: {
            title: media_link.title
          },
          participatory_space: {
            title: conference.title
          }
        }
      end

      it "destroys the media link" do
        subject.call
        expect { media_link.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", media_link, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end
end
