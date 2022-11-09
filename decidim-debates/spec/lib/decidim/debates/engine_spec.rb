# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Engine do
  describe "decidim_debates.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:debates_component, organization:) }
    let(:original_records) do
      { debates: create_list(:debate, 3, component:, author: original_user) }
    end
    let(:transferred_debates) { Decidim::Debates::Debate.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_debates.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_debates)
    end
  end
end
