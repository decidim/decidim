# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Engine do
  it "loads engine mailer previews" do
    expect(ActionMailer::Preview.all).to include(Decidim::Initiatives::InitiativesMailerPreview)
  end

  describe "decidim_initiatives.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:post_component, organization:) }
    let(:original_records) do
      {
        initiatives: create_list(:initiative, 3, organization:, author: original_user),
        votes: create_list(:initiative_user_vote, 5, author: original_user)
      }
    end
    let(:transferred_initiatives) { Decidim::Initiative.where(author: target_user).order(:id) }
    let(:transferred_votes) { Decidim::InitiativesVote.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_initiatives.count).to eq(3)
      expect(transferred_votes.count).to eq(5)
      expect(transfer.records.count).to eq(8)
      expect(transferred_resources).to eq(transferred_initiatives + transferred_votes)
    end
  end
end
