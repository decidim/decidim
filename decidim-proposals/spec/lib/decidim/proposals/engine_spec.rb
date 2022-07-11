# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Engine do
  describe "decidim_proposals.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:proposal_component, :with_votes_enabled, organization: organization) }
    let(:proposal1) { create(:proposal, component: component) }
    let(:proposal2) { create(:proposal, component: component) }
    let(:proposal3) { create(:proposal, component: component) }
    let(:original_records) do
      {
        votes: [
          create(:proposal_vote, proposal: proposal1, author: original_user),
          create(:proposal_vote, proposal: proposal2, author: original_user),
          create(:proposal_vote, proposal: proposal3, author: original_user)
        ]
      }
    end
    let(:transferred_votes) { Decidim::Proposals::ProposalVote.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_votes.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_votes)
    end
  end
end
