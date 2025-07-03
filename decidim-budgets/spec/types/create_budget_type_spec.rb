# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Budgets
  describe CreateBudgetType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetsMutationType }
    let(:locale) { "en" }
    let(:model) { create(:budgets_component) }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:resource_class) { Decidim::Budgets::Budget }
    let(:total_budget) { 1234 }
    let(:variables) do
      {
        input: {
          attributes: {
            title: { en: title_en },
            totalBudget: 1234,
            description: { en: description_en }
          }
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: CreateBudgetInput!) {
          createBudget(input: $input) {
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
      GRAPHQL
    end

    context "with admin user" do
      it_behaves_like "API creatable budget" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        budget = response["createBudget"]
        expect(budget).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API creatable budget" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
