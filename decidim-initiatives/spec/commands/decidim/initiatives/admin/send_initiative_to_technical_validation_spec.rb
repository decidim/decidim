# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe SendInitiativeToTechnicalValidation do
        subject { described_class.new(initiative, user) }

        let(:initiative) { create :initiative }
        let(:organization) { initiative.organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let!(:another_admin) { create(:user, :admin, organization: organization) }

        context "when everything is ok" do
          it "sends the initiative to technical validation" do
            expect { subject.call }.to change(initiative, :state).from("published").to("validating")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:send_to_technical_validation, initiative, user)
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "notifies the admins" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .once
              .ordered
              .with(
                event: "decidim.events.initiatives.admin.initiative_sent_to_technical_validation",
                event_class: Decidim::Initiatives::Admin::InitiativeSentToTechnicalValidationEvent,
                force_send: true,
                resource: initiative,
                affected_users: a_collection_containing_exactly(another_admin)
              )

            subject.call
          end
        end
      end
    end
  end
end
