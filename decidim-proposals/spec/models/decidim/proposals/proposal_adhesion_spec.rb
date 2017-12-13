# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalAdhesion do
      subject { proposal_adhesion }

      let!(:organization) { create(:organization) }
      let!(:feature) { create(:feature, organization: organization, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:author) { create(:user, organization: organization) }
      let!(:user_group) { create(:user_group, verified_at: DateTime.now) }
      let!(:proposal) { create(:proposal, feature: feature, author: author) }
      let!(:proposal_adhesion) { build(:proposal_adhesion, proposal: proposal, author: author,
        user_group: user_group) }

      it "is valid" do
        expect(proposal_adhesion).to be_valid
      end

      it "has an associated author" do
        expect(proposal_adhesion.author).to be_a(Decidim::User)
      end

      it "has an associated proposal" do
        expect(proposal_adhesion.proposal).to be_a(Decidim::Proposals::Proposal)
      end

      it "validates uniqueness for author and user_group and proposal combination" do
        proposal_adhesion.save!
        expect do
          create(:proposal_adhesion, proposal: proposal, author: author,
            user_group: user_group)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      context "when no author" do
        before do
          proposal_adhesion.author = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when no user_group" do
        before do
          proposal_adhesion.user_group = nil
        end

        it { is_expected.to be_valid }
      end

      context "when no proposal" do
        before do
          proposal_adhesion.proposal = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when proposal and author have different organization" do
        let(:other_author) { create(:user) }
        let(:other_proposal) { create(:proposal) }

        it "is invalid" do
          proposal_adhesion = build(:proposal_adhesion, proposal: other_proposal, author: other_author)
          expect(proposal_adhesion).to be_invalid
        end
      end

      context "when proposal is rejected" do
        let!(:proposal) { create(:proposal, :rejected, feature: feature, author: author) }

        it { is_expected.to be_invalid }
      end

      context "when retrieving for_listing" do
        before do
          proposal_adhesion.save!
        end
        let!(:other_user_group) { create(:user_group, verified_at: DateTime.now) }
        let!(:other_proposal_adhesion_1) {
          create(:proposal_adhesion, proposal: proposal, author: author)
        }
        let!(:other_proposal_adhesion_2) {
          create(:proposal_adhesion, proposal: proposal, author: author, user_group: other_user_group)
        }
        it "should sort user_grup adhesions first and then by created_at" do
          expected_sorting= [
            proposal_adhesion.id, other_proposal_adhesion_2.id,
            other_proposal_adhesion_1.id,
          ]
          expect(proposal.adhesions.for_listing.pluck(:id)).to eq(expected_sorting)
        end
      end
    end
  end
end
