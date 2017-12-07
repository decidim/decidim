# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Proposals
    describe UnadhereProposal do
      describe 'User unadheres proposal' do
        let(:adhesion) { create(:proposal_adhesion) }
        let(:command) { described_class.new(adhesion.proposal, adhesion.author) }

        it 'broadcasts ok' do
          expect(adhesion).to be_valid
          expect { command.call }.to broadcast :ok
        end

        it 'Removes the adhesion' do
          expect(adhesion).to be_valid
          expect do
            command.call
          end.to change { ProposalAdhesion.count }.by(-1)
        end

        it 'Decreases the adhesions counter by one' do
          proposal = adhesion.proposal
          expect(ProposalAdhesion.count).to eq(1)
          expect do
            command.call
            proposal.reload
          end.to change { proposal.proposal_adhesions_count }.by(-1)
        end
      end

      describe 'Organization unadheres proposal' do
        let(:adhesion) { create(:organization_proposal_adhesion) }
        let(:command) { described_class.new(adhesion.proposal, adhesion.author, adhesion.user_group) }

        it 'broadcasts ok' do
          expect(adhesion).to be_valid
          expect { command.call }.to broadcast :ok
        end

        it 'Removes the adhesion' do
          expect(adhesion).to be_valid
          expect do
            command.call
          end.to change { ProposalAdhesion.count }.by(-1)
        end

        it 'Do not decreases the adhesion counter by one' do
          expect(adhesion).to be_valid
          command.call

          proposal = adhesion.proposal
          proposal.reload
          expect(proposal.proposal_adhesions_count).to be_zero
        end
      end
    end
  end
end