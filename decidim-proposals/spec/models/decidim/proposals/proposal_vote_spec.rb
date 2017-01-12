# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVote do
      let!(:organization) { create(:organization) }
      let!(:feature) { create(:feature, organization: organization)}      
      let!(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:author) { create(:user, organization: organization) }
      let!(:proposal) { create(:proposal, feature: feature, author: author)}
      let!(:proposal_vote) { create(:proposal_vote, proposal: proposal, author: author) }

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
        expect {
          create(:proposal_vote, proposal: proposal, author: author)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "is invalid if proposal and author have different organizations" do
        author = create(:user)
        proposal = create(:proposal)
        proposal_vote = build(:proposal_vote, proposal: proposal, author: author)
        expect(proposal_vote).to be_invalid
      end
    end
  end
end
