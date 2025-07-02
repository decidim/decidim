# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Budgets
  describe DeleteBudgetType, type: :graphql do
    include_context "with a graphql type and authenticated user"

    let(:model) { create(:budgets_component) }
    let!(:budget) { create(:budget, component: model, total_budget: 1_000) }

    let(:query) do
      %(
        mutation {
          component(id: "#{model.id}") {
            ...on BudgetsMutation { deleteBudget(id: #{budget.id}) { id } }
          }
        }
      )
    end

    context "with admin user" do
      it_behaves_like "deletable budget" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        budget = response["component"]["deleteBudget"]
        expect(budget).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "deletable budget" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
