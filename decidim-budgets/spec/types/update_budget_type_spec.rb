# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe UpdateBudgetType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:locale) { "en" }
    let(:current_component) { create(:budgets_component, organization: current_organization) }
    let!(:component) { current_component }

    let(:type_class) { Decidim::Budgets::UpdateBudgetType }
    let(:root_klass) { BudgetMutationType }
    let(:root_value) { model }

    let!(:model) { create(:budget, component: current_component, total_budget: 1_000) }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:resource_class) { Decidim::Budgets::Budget }
    let(:total_budget) { 1234 }
    let(:budget_id) { model.id }
    let(:variables) do
      {
        component_id: current_component.id,
        budget_id:,
        input: {
          attributes: {
            title: { en: title_en },
            description: { en: description_en },
            totalBudget: total_budget
          }
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation( $input: UpdateBudgetInput!) {
          updateBudget(input: $input) {
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
      it_behaves_like "API updatable budget" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
      end
    end

    context "with api_user" do
      it_behaves_like "API updatable budget" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
