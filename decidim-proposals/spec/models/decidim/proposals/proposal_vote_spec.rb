# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVote do
      subject { proposal_vote }

      let!(:organization) { create(:organization) }
      let!(:component) { create(:component, organization: organization, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:author) { create(:user, organization: organization) }
      let!(:proposal) { create(:proposal, component: component, users: [author]) }
      let!(:proposal_vote) { build(:proposal_vote, proposal: proposal, author: author) }

      it "is valid" do
        expect(proposal_vote).to be_valid
      end

      it "has an associated author" do
        expect(proposal_vote.author).to be_a(Decidim::User)
      end

      it "has an associated proposal" do
        expect(proposal_vote.proposal).to be_a(Decidim::Proposals::Proposal)
      end

      it "validates uniqueness for author and proposal combination" do
        proposal_vote.save!
        expect do
          create(:proposal_vote, proposal: proposal, author: author)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      context "when no author" do
        before do
          proposal_vote.author = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when no proposal" do
        before do
          proposal_vote.proposal = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when proposal and author have different organization" do
        let(:other_author) { create(:user) }
        let(:other_proposal) { create(:proposal) }

        it "is invalid" do
          proposal_vote = build(:proposal_vote, proposal: other_proposal, author: other_author)
          expect(proposal_vote).to be_invalid
        end
      end

      context "when proposal is rejected" do
        let!(:proposal) { create(:proposal, :rejected, component: component, users: [author]) }

        it { is_expected.to be_invalid }
      end
    end
  end
end
