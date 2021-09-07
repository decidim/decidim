# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe DestroyPollingStation do
        subject { described_class.new(polling_station, user) }

        let(:polling_station) { create :polling_station }
        let(:user) { create :user, :admin, organization: polling_station.voting.organization }

        context "when everything is ok" do
          it "destroys the polling station" do
            subject.call

            expect { polling_station.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:delete, polling_station, user, visibility: "all")
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
