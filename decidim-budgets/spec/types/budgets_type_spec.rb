# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Budgets
    describe BudgetsType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { create(:budgets_component) }

      it_behaves_like "a component query type"

      describe "budgets" do
        let!(:budgets) { create_list(:budget, 2, component: model) }
        let!(:other_budgets) { create_list(:budget, 2) }

        let(:query) { "{ budgets { edges { node { id } } } }" }

        it "returns the budgets" do
          ids = response["budgets"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*budgets.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_budgets.map(&:id).map(&:to_s))
        end
      end

      describe "budget" do
        let(:query) { "query Budget($id: ID!){ budget(id: $id) { id } }" }
        let(:budget) { budgets.sample }
        let(:variables) { { id: budget.id.to_s } }

        context "when the budget belongs to the component" do
          let!(:budget) { create(:budget, component: model) }

          it "finds the budget" do
            expect(response["budget"]["id"]).to eq(budget.id.to_s)
          end
        end

        context "when the budget does not belong to the component" do
          let!(:budget) { create(:budget, component: create(:budgets_component)) }

          it "returns null" do
            expect(response["budget"]).to be_nil
          end
        end
      end
    end
  end
end
