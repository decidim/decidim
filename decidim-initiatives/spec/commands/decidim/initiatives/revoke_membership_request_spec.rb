# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe RevokeMembershipRequest do
      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, :created, organization: organization) }
      let(:author) { initiative.author }
      let(:membership_request) { create(:initiatives_committee_member, initiative: initiative, state: "requested") }
      let(:command) { described_class.new(membership_request) }

      context "when everything is ok" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "notifies author" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.initiatives.revoke_membership_request",
              event_class: Decidim::Initiatives::RevokeMembershipRequestEvent,
              resource: initiative,
              affected_users: [membership_request.user],
              force_send: true,
              extra: { author: initiative.author }
            )

          command.call
        end

        it "revokes committee membership request" do
          expect do
            command.call
          end.to change(membership_request, :state).from("requested").to("rejected")
        end
      end
    end
  end
end
