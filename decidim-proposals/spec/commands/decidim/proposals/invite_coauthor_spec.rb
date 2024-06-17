# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe InviteCoauthor do
      let!(:proposal) { create(:proposal) }

      let(:coauthor) { create(:user, organization: proposal.organization) }
      let(:command) { described_class.new(proposal, coauthor) }

      describe "when the coauthor is valid" do
        before do
          allow(SecureRandom).to receive(:uuid).and_return("123")
        end

        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "generates a notification" do
          perform_enqueued_jobs do
            expect { command.call }.to change(Decidim::Notification, :count).by(1)
          end
        end

        it_behaves_like "fires an ActiveSupport::Notification event", "decidim.events.proposals.coauthor_invited"

        it "notifies the coauthor about the invitation" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.coauthor_invited",
              event_class: Decidim::Proposals::CoauthorInvitedEvent,
              resource: proposal,
              affected_users: [coauthor],
              extra: {
                coauthor_id: coauthor.id,
                uuid: "#{proposal.organization.id}-123"
              }
            )

          command.call
        end
      end

      describe "when the coauthor is already an author" do
        before do
          proposal.add_coauthor(coauthor)
        end

        it "does not generate a notification" do
          expect { command.call }.not_to change(Decidim::Notification, :count)
        end
      end

      describe "when the coauthor is nil" do
        let(:coauthor) { nil }

        it "broadcasts :invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
