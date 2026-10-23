# frozen_string_literal: true

require "spec_helper"

describe "Budget orders" do
  let(:user) { create(:user, :confirmed) }
  let(:participatory_space) { create(:participatory_process, :with_steps, :published, organization: user.organization) }
  let(:component) { create(:budgets_component, :published, :with_vote_threshold_percent, participatory_space:, vote_threshold_percent: 50) }
  let(:budget) { create(:budget, component:, total_budget: 100_000) }
  let(:project) { create(:project, budget:, budget_amount: 10_000) }
  let!(:order) { create(:order, user:, budget:) }
  let(:budgets_path) { Decidim::EngineRouter.main_proxy(component).budgets_path }

  before do
    order.projects << project
    host! user.organization.host
    login_as user, scope: :user
  end

  describe "POST checkout" do
    context "when the order is below the vote threshold" do
      it "shows the alert on the budgets page" do
        post(Decidim::EngineRouter.main_proxy(component).checkout_budget_order_path(budget))

        expect(response).to redirect_to(budgets_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("orders.checkout.error", scope: "decidim"))
      end
    end
  end

  describe "DELETE destroy" do
    context "when the order is not checked out" do
      it "shows the alert on the budgets page" do
        delete(Decidim::EngineRouter.main_proxy(component).budget_order_path(budget))

        expect(response).to redirect_to(budgets_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("orders.destroy.error", scope: "decidim"))
      end
    end
  end
end
