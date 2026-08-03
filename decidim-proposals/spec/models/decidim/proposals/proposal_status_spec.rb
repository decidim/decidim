# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalStatus do
      subject { proposal_status }

      let(:component) { build(:proposal_component) }
      let(:organization) { component.participatory_space.organization }
      let(:proposal_status) { create(:proposal_status, token:, component:) }
      let!(:proposal) { create(:proposal, component:) }
      let(:token) { "some_status" }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      context "when creating" do
        let(:proposal_status) { build(:proposal_status, token:, component:) }

        it "does not generate a new token if exists" do
          expect(proposal_status.token).to eq("some_status")
          proposal_status.update!(title: { en: "New title" })
          expect(proposal_status.token).to be_present
          expect(proposal_status.token).to eq("some_status")
        end
      end

      context "when no token" do
        let(:token) { nil }

        it "generates a token on creation" do
          proposal_status.save!
          expect(proposal_status.token).to be_present
        end
      end

      context "when destroying" do
        it "destroys the proposal status" do
          proposal_status.destroy
          expect { proposal_status.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context "when proposals assigned" do
          before do
            proposal.update!(proposal_status:)
          end

          it "prevents deletion" do
            expect { proposal_status.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
          end
        end
      end
    end
  end
end
