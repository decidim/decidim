# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Engine do
  describe "decidim_budgets.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:budgets_component, organization: organization) }
    let(:budget1) { create(:budget, component: component) }
    let(:budget2) { create(:budget, component: component) }
    let(:budget3) { create(:budget, component: component) }
    let(:original_records) do
      {
        orders: [
          create(:order, budget: budget1, user: original_user),
          create(:order, budget: budget2, user: original_user),
          create(:order, budget: budget3, user: original_user)
        ]
      }
    end
    let(:transferred_orders) { Decidim::Budgets::Order.where(user: target_user) }

    it "handles authorization transfer correctly" do
      expect(transferred_orders.count).to eq(3)
    end
  end
end
