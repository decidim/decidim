# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalState do
      subject { proposal_state }

      let(:component) { build(:proposal_component) }
      let(:organization) { component.participatory_space.organization }
      let(:proposal_state) { create(:proposal_state, token:, component:) }
      let!(:proposal) { create(:proposal, component:) }
      let(:token) { "some_status" }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      context "when creating" do
        let(:proposal_state) { build(:proposal_state, token:, component:) }

        it "does not generate a new token if exists" do
          expect(proposal_state.token).to eq("some_status")
          proposal_state.update!(title: { en: "New title" })
          expect(proposal_state.token).to be_present
          expect(proposal_state.token).to eq("some_status")
        end
      end

      context "when no token" do
        let(:token) { nil }

        it "generates a token on creation" do
          proposal_state.save!
          expect(proposal_state.token).to be_present
        end
      end

      context "when destroying" do
        it "destroys the proposal state" do
          proposal_state.destroy
          expect { proposal_state.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context "when proposals assigned" do
          before do
            proposal.update!(proposal_state:)
          end

          it "prevents deletion" do
            expect { proposal_state.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
          end
        end
      end
    end
  end
end
