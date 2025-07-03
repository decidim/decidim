# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Budgets
  describe DeleteBudgetType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetsMutationType }
    let(:model) { create(:budgets_component) }
    let!(:budget) { create(:budget, component: model, total_budget: 1_000) }

    let(:query) do
      %( mutation { deleteBudget(id: #{budget.id}) { id } })
    end

    context "with admin user" do
      it_behaves_like "API deletable budget" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        budget = response["deleteBudget"]
        expect(budget).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API deletable budget" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
