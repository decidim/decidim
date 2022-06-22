# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Engine do
  describe "decidim_debates.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:debates_component, organization: organization) }
    let(:original_records) do
      { debates: create_list(:debate, 3, component: component, author: original_user) }
    end
    let(:transferred_debates) { Decidim::Debates::Debate.where(author: target_user) }

    it "handles authorization transfer correctly" do
      expect(transferred_debates.count).to eq(3)
    end
  end
end
