# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe DeleteBudgetType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetMutationType }
    let!(:model) { create(:budget, component: current_component, total_budget: 1_000) }
    let(:current_component) { create(:budgets_component) }
    let(:current_organization) { current_component.organization }

    let(:query) do
      %( mutation { deleteBudget(id: #{model.id}) { id } })
    end

    shared_examples "API deletable budget" do
      it "deletes the budget" do
        expect(model.deleted_at).to be_nil
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Budgets::Budget, :count).by(-1)
        expect(model.reload.deleted_at).to be_present
      end

      context "when missing budget" do
        context "when budget is missing" do
          let(:query) { %( mutation { deleteBudget(id: 9999999) { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Budget not found")
          end
        end

        context "when budget id is not integer" do
          let(:query) { %( mutation { deleteBudget(id: "aaaa") { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Budget not found")
          end
        end

        context "when budget is already deleted" do
          let!(:model) { create(:budget, component: current_component, total_budget: 1_000) }

          before { model.destroy }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Budget not found")
          end
        end

        context "when budget belongs to another component" do
          let(:model2) { create(:budget, component: current_component2, total_budget: 1_000) }
          let(:current_component2) { create(:budgets_component, organization: current_organization) }
          let(:query) { %( mutation { deleteBudget(id: #{model2.id}) { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Budget not found")
          end
        end
      end
    end

    it_behaves_like "admin API access checks", "API deletable budget"
  end
end
