# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe PublishInitiative do
        subject { described_class.new(initiative, user) }

        let(:initiative) { create :initiative, :created }
        let(:user) { create :user, :admin, :confirmed, organization: initiative.organization }

        context "when the initiative is already published" do
          let(:initiative) { create :initiative }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "publishes the initiative" do
            expect { subject.call }.to change(initiative, :state).from("created").to("published")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:publish, initiative, user, visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "increments the author's score" do
            expect { subject.call }.to change { Decidim::Gamification.status_for(initiative.author, :initiatives).score }.by(1)
          end
        end
      end
    end
  end
end
