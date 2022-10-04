# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Engine do
  describe "decidim_elections.authorization_transfer" do
    include_context "authorization transfer"

    let(:election) { create(:election, organization:) }
    let(:original_records) do
      { votes: create_list(:vote, 3, election:, user: original_user) }
    end
    let(:transferred_votes) { Decidim::Elections::Vote.where(user: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_votes.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_votes)
    end
  end
end
