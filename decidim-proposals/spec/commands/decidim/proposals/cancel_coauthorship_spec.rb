# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CancelCoauthorship do
      let!(:proposal) { create(:proposal) }

      let(:coauthor) { create(:user, organization: proposal.organization) }
      let!(:notification) do
        create(:notification, event_class: "Decidim::Proposals::CoauthorInvitedEvent", resource: proposal, extra: { uuid: "some-uuid", coauthor_id: coauthor&.id, other: "Other data" })
      end
      let!(:another_notification) do
        create(:notification, event_class: "Decidim::Proposals::CoauthorInvitedEvent", resource: proposal, extra: { uuid: "another-uuid", coauthor_id: "another-id", other: "Other data" })
      end

      let(:command) { described_class.new(proposal, coauthor) }

      describe "when the coauthor is valid" do
        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "removes the coauthor from the proposal" do
          expect { command.call }.to change(Decidim::Notification, :count).by(-1)
          expect(Decidim::Notification.all.to_a).to eq([another_notification])
        end
      end

      describe "when the coauthor is not valid" do
        let(:coauthor) { nil }

        it "broadcasts :invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when the coauthor is already an author" do
        let!(:coauthor) { create(:user, organization: proposal.organization) }

        before do
          proposal.add_coauthor(coauthor)
        end

        it "does not remove the coauthor from the proposal" do
          expect do
            command.call
          end.not_to(change(Decidim::Notification, :count))
        end
      end
    end
  end
end
