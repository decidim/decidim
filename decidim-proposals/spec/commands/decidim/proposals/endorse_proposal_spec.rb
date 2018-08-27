# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe EndorseProposal do
      let(:proposal) { create(:proposal) }
      let(:current_user) { create(:user, organization: proposal.component.organization) }

      describe "User endorses Proposal" do
        let(:command) { described_class.new(proposal, current_user) }

        context "when in normal conditions" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new endorsement for the proposal" do
            expect do
              command.call
            end.to change(ProposalEndorsement, :count).by(1)
          end

          it "notifies all followers of the endorser that the proposal has been endorsed" do
            follower = create(:user, organization: proposal.organization)
            create(:follow, followable: current_user, user: follower)
            author_follower = create(:user, organization: proposal.organization)
            create(:follow, followable: proposal.authors.first, user: author_follower)

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.proposal_endorsed",
                event_class: Decidim::Proposals::ProposalEndorsedEvent,
                resource: proposal,
                recipient_ids: [follower.id],
                extra: {
                  endorser_id: current_user.id
                }
              )

            command.call
          end
        end

        context "when the endorsement is not valid" do
          before do
            proposal.update(answered_at: Time.current, state: "rejected")
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new endorsement for the proposal" do
            expect do
              command.call
            end.not_to change(ProposalEndorsement, :count)
          end
        end
      end

      describe "Organization endorses Proposal" do
        let(:user_group) { create(:user_group, verified_at: Time.current) }
        let(:command) { described_class.new(proposal, current_user, user_group.id) }

        before do
          current_user.user_groups << user_group
          current_user.save!
        end

        context "when in normal conditions" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast :ok
          end

          it "Creates an endorsement" do
            expect do
              command.call
            end.to change(ProposalEndorsement, :count).by(1)
          end
        end

        context "when the endorsement is not valid" do
          before do
            proposal.update(answered_at: Time.current, state: "rejected")
          end

          it "Do not increase the endorsements counter by one" do
            command.call
            proposal.reload
            expect(proposal.proposal_endorsements_count).to be_zero
          end
        end
      end
    end
  end
end
