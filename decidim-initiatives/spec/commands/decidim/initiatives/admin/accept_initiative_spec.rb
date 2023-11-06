# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe AcceptInitiative do
        subject { described_class.new(initiative, user) }

        let(:initiative) { create(:initiative, :validating) }
        let(:user) { create(:user, :admin, :confirmed, organization: initiative.organization) }

        context "when the initiative is already accepted" do
          let(:initiative) { create(:initiative, :accepted) }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "accepts the initiative" do
            expect { subject.call }.to change(initiative, :state).from("validating").to("accepted")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:accept, initiative, user)
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
