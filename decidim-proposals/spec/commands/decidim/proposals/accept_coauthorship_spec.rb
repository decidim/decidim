# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AcceptCoauthorship do
      let!(:proposal) { create(:proposal) }

      let(:coauthor) { create(:user, organization: proposal.organization) }
      let(:notification) do
        create(:notification, event_class: "Decidim::Proposals::CoauthorInvitedEvent", extra: { uuid: "some-uuid", coauthor_id: coauthor&.id, other: "Other data" })
      end

      let(:command) { described_class.new(proposal, coauthor, notification) }

      describe "when the coauthor is valid" do
        it "adds the coauthor to the proposal" do
          expect do
            command.call
          end.to change { proposal.coauthorships.count }.by(1)
        end

        it "deletes the extra data from the notification" do
          command.call
          expect(notification.extra).to eq({ "other" => "Other data" })
        end

        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
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
