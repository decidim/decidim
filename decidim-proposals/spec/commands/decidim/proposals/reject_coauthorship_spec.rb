# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe RejectCoauthorship do
      let!(:proposal) { create(:proposal) }

      let(:coauthor) { create(:user, organization: proposal.organization) }
      let(:command) { described_class.new(proposal, coauthor) }

      let!(:notification) do
        create(:notification, :proposal_coauthor_invite, user: coauthor, resource: proposal)
      end

      let!(:another_notification) do
        create(:notification, :proposal_coauthor_invite, resource: proposal)
      end

      describe "when the coauthor is valid" do
        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "removes the notification" do
          expect { command.call }.to change(Decidim::Notification, :count).by(-1)
          expect(Decidim::Notification.all.to_a).to eq([another_notification])
        end

        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.events.proposals.rejected_coauthorship"
        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.events.proposals.coauthor_rejected_invite"

        it "notifies the coauthor and existing authors about the new coauthorship" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.coauthor_rejected_invite",
              event_class: Decidim::Proposals::CoauthorRejectedInviteEvent,
              resource: proposal,
              affected_users: proposal.authors,
              extra: { coauthor_id: coauthor.id }
            )
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.rejected_coauthorship",
              event_class: Decidim::Proposals::RejectedCoauthorshipEvent,
              resource: proposal,
              affected_users: [coauthor]
            )

          command.call
        end
      end

      describe "when the coauthor is nil" do
        let(:coauthor) { nil }
        let(:notification) { create(:notification, :proposal_coauthor_invite, resource: proposal) }

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
