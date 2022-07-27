# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe DestroyPollingOfficer do
        subject { described_class.new(polling_officer, current_user) }

        let(:voting) { create :voting }
        let!(:user) { create :user, :confirmed, organization: voting.organization }
        let(:polling_officer) { create :polling_officer, user:, voting: }
        let!(:current_user) { create :user, email: "some_email@example.org", organization: voting.organization }

        context "when everything is ok" do
          let(:log_info) do
            {
              resource: {
                title: user.name
              }
            }
          end

          it "destroys the polling_officer" do
            subject.call
            expect { polling_officer.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("delete", polling_officer, current_user, log_info)
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)

            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "destroy"
          end
        end
      end
    end
  end
end
