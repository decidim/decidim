# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe DeleteBudgetType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetsMutationType }
    let(:model) { create(:budgets_component) }
    let!(:budget) { create(:budget, component: model, total_budget: 1_000) }

    let(:query) do
      %( mutation { deleteBudget(id: #{budget.id}) { id } })
    end

    shared_examples "API deletable budget" do
      it "deletes the budget" do
        expect(budget.deleted_at).to be_nil
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Budgets::Budget, :count).by(-1)
        expect(budget.reload.deleted_at).to be_present
      end
    end

    shared_context "when missing budget" do
      context "when budget is missing" do
        let(:query) { %( mutation { deleteBudget(id: 9999999) { id } } ) }

        it "returns an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Budget not found")
        end
      end

      context "when budget id is not integer" do
        let(:query) { %( mutation { deleteBudget(id: "aaaa") { id } } ) }

        it "returns an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Budget not found")
        end
      end
    end

    context "with admin user" do
      it_behaves_like "API deletable budget" do
        let!(:user_type) { :admin }
      end

      include_context "when missing budget"
    end

    context "with normal user" do
      it "returns an error" do
        expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
      end

      include_context "when missing budget"
    end

    context "with visitor user" do
      let!(:current_user) { nil }

      it "returns nil" do
        expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
      end

      include_context "when missing budget"
    end

    context "with api_user" do
      it_behaves_like "API deletable budget" do
        let!(:user_type) { :api_user }
      end

      include_context "when missing budget"
    end
  end
end
