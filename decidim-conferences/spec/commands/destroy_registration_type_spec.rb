# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::DestroyRegistrationType, versioning: true do
    subject { described_class.new(registration_type, current_user) }

    let(:conference) { create(:conference) }
    let(:registration_type) { create :registration_type, conference: }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }

    context "when everything is ok" do
      let(:log_info) do
        {
          resource: {
            title: registration_type.title
          },
          participatory_space: {
            title: conference.title
          }
        }
      end

      it "destroys the registration type" do
        subject.call
        expect { registration_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", registration_type, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end
end
