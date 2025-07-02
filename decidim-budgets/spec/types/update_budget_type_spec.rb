# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Budgets
  describe UpdateBudgetType, type: :graphql do
    include_context "with a graphql type and authenticated user"

    let(:locale) { "en" }
    let(:model) { create(:budgets_component) }
    let!(:budget) { create(:budget, component: model, total_budget: 1_000) }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:resource_class) { Decidim::Budgets::Budget }
    let(:total_budget) { 1234 }

    let(:query) do
      <<~GRAPHQL
        mutation {
          component(id: "#{model.id}") {
            ...on BudgetsMutation {
              updateBudget(
              input: {
                id: "#{budget.id}",
                attributes: {
                  title: {en: "#{title_en}"},
                  totalBudget: "#{total_budget}",
                  description: {en: "#{description_en}"}
                }
              }) {
                id
                title {
                  translation(locale: "#{locale}")
                }
                description {
                  translation(locale: "#{locale}")
                }
                total_budget
              }
            }
          }
        }
      GRAPHQL
    end

    context "with admin user" do
      it_behaves_like "API updatable budget" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        budget = response["component"]["updateBudget"]
        expect(budget).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API updatable budget" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
