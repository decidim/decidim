# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AdhereProposal do
      let(:proposal) { create(:proposal) }
      let(:current_user) { create(:user, organization: proposal.feature.organization) }
        
      describe 'User adheres Proposal' do
        let(:command) { described_class.new(proposal, current_user) }

        context "in normal conditions" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new adhesion for the proposal" do
            expect do
              command.call
            end.to change { ProposalAdhesion.count }.by(1)
          end
        end

        context "when the adhesion is not valid" do
          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(ProposalAdhesion).to receive(:valid?).and_return(false)
            # rubocop:enable RSpec/AnyInstance
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new adhesion for the proposal" do
            expect do
              command.call
            end.to change { ProposalAdhesion.count }.by(0)
          end
        end
      end


      describe 'Organization adheres Proposal' do
        let(:user_group) { create(:user_group) }
        let(:user_group_membership) { create(:user_group_membership, user: current_user, user_group: user_group) }
        let(:command) { described_class.new(proposal, current_user, user_group.id) }

        context "in normal conditions" do
          it 'broadcasts ok' do
            expect { command.call }.to broadcast :ok
          end

          it 'Creates an adhesion' do
            expect do
              command.call
            end.to change { ProposalAdhesion.count }.by(1)
          end
        end

        context "when the adhesion is not valid" do
          it 'Do not increases the vote counter by one' do
            command.call
            proposal.reload
            expect(proposal.proposal_adhesions_count).to be_zero
          end
        end
      end

    end
  end
end
