# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe PublishElection do
        subject { described_class.new(election, current_user).call }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :admin, organization:) }
        let(:component) { create(:elections_component, participatory_space: create(:participatory_process, organization:)) }
        let(:election) { create(:election, component:, published_at: nil) }

        context "when the election is not published yet" do
          it "broadcasts :ok" do
            expect { subject }.to broadcast(:ok, election)
          end

          it "publishes the election" do
            expect { subject }.to change { election.reload.published? }.from(false).to(true)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:publish, election, current_user, visibility: "all")
              .and_call_original

            expect { described_class.new(election, current_user).call }.to change(Decidim::ActionLog, :count)
            expect(Decidim::ActionLog.last.version).to be_present
            expect(Decidim::ActionLog.last.version.event).to eq "update"
          end
        end

        context "when the election is already published" do
          before { election.update!(published_at: 1.day.ago) }

          it "broadcasts :invalid" do
            expect { subject }.to broadcast(:invalid)
          end

          it "does not publish the election again" do
            expect { subject }.not_to(change { election.reload.updated_at })
          end

          it "does not trace the action" do
            expect(Decidim.traceability).not_to receive(:perform_action!)
            described_class.new(election, current_user).call
          end
        end
      end
    end
  end
end
