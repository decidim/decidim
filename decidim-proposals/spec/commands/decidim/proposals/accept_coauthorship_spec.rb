# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AcceptCoauthorship do
      let!(:proposal) { create(:proposal) }

      let(:coauthor) { create(:user, organization: proposal.organization) }
      let!(:notification) do
        create(:notification, :proposal_coauthor_invite, resource: proposal, user: coauthor)
      end
      let!(:another_notification) do
        create(:notification, :proposal_coauthor_invite, resource: proposal)
      end

      let(:command) { described_class.new(proposal, coauthor) }

      describe "when the coauthor is valid" do
        it "adds the coauthor to the proposal" do
          expect do
            command.call
          end.to change { proposal.coauthorships.count }.by(1)
        end

        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "removes the notification" do
          expect { command.call }.to change(Decidim::Notification, :count).by(-1)
          expect(Decidim::Notification.all.to_a).to eq([another_notification])
        end

        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.events.proposals.accepted_coauthorship"
        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.events.proposals.coauthor_accepted_invite"

        it "notifies the coauthor and existing authors about the new coauthorship" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.coauthor_accepted_invite",
              event_class: Decidim::Proposals::CoauthorAcceptedInviteEvent,
              resource: proposal,
              affected_users: proposal.authors.reject { |author| author == coauthor },
              extra: { coauthor_id: coauthor.id }
            )
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.accepted_coauthorship",
              event_class: Decidim::Proposals::AcceptedCoauthorshipEvent,
              resource: proposal,
              affected_users: [coauthor]
            )

          command.call
        end
      end

      describe "when the coauthor is not in the same organization" do
        let(:coauthor) { create(:user) }

        it "does not add the coauthor to the proposal" do
          expect do
            command.call
          end.not_to(change { proposal.coauthorships.count })
        end

        it "broadcasts :invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when the coauthor is already an author" do
        let!(:coauthor) { create(:user, organization: proposal.organization) }

        before do
          proposal.add_coauthor(coauthor)
        end

        it "does not add the coauthor to the proposal" do
          expect do
            command.call
          end.not_to(change { proposal.coauthorships.count })
        end

        it "broadcasts :invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when the coauthor is nil" do
        let(:coauthor) { nil }
        let(:notification) { create(:notification, :proposal_coauthor_invite) }

        it "does not add the coauthor to the proposal" do
          expect do
            command.call
          end.not_to(change { proposal.coauthorships.count })
        end

        it "broadcasts :invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
