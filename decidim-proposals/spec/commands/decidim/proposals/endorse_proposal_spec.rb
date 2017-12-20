# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe EndorseProposal do
      let(:proposal) { create(:proposal) }
      let(:current_user) { create(:user, organization: proposal.feature.organization) }

      describe "User endorses Proposal" do
        let(:command) { described_class.new(proposal, current_user) }

        context "when in normal conditions" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new endorsement for the proposal" do
            expect do
              command.call
            end.to change { ProposalEndorsement.count }.by(1)
          end
        end

        context "when the endorsement is not valid" do
          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(ProposalEndorsement).to receive(:valid?).and_return(false)
            # rubocop:enable RSpec/AnyInstance
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new endorsement for the proposal" do
            expect do
              command.call
            end.to change { ProposalEndorsement.count }.by(0)
          end
        end
      end

      describe "Organization endorses Proposal" do
        let(:user_group) { create(:user_group, verified_at: DateTime.current) }
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
            end.to change { ProposalEndorsement.count }.by(1)
          end
        end

        context "when the endorsement is not valid" do
          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(ProposalEndorsement).to receive(:valid?).and_return(false)
            # rubocop:enable RSpec/AnyInstance
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
