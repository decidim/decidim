# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe DestroyProposalStatus do
        subject { described_class.new(status, user) }
        let!(:component) { create(:proposal_component) }
        let(:current_organization) { component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization: current_organization) }
        let!(:status) { create(:proposal_status, component:, token: "editable") }

        context "when everything is ok" do
          it "destroys the result" do
            subject.call
            expect { status.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:delete, status, user)
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
