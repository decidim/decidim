# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe DiscardInitiative do
        subject { described_class.new(initiative, user) }

        let(:initiative) { create(:initiative, :validating) }
        let(:user) { create(:user, :admin, :confirmed, organization: initiative.organization) }

        context "when the initiative is already discarded" do
          let(:initiative) { create(:initiative, :discarded) }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "discards the initiative" do
            expect { subject.call }.to change(initiative, :state).from("validating").to("discarded")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:discard, initiative, user)
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
