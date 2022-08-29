# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe DestroyMonitoringCommitteeMember do
        subject { described_class.new(monitoring_committee_member, current_user) }

        let(:voting) { create :voting }
        let!(:user) { create :user, :confirmed, organization: voting.organization }
        let(:monitoring_committee_member) { create :monitoring_committee_member, user:, voting: }
        let!(:current_user) { create :user, email: "some_email@example.org", organization: voting.organization }

        context "when everything is ok" do
          let(:log_info) do
            {
              resource: {
                title: user.name
              }
            }
          end

          it "destroys the monitoring committee member" do
            subject.call
            expect { monitoring_committee_member.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("delete", monitoring_committee_member, current_user, log_info)
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
