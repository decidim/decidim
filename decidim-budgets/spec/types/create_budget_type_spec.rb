# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Budgets
  describe CreateBudgetType, type: :graphql do
    include_context "with a graphql type and authenticated user"

    let(:locale) { "en" }
    let(:model) { create(:budgets_component) }
    let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
    let(:description) { Decidim::Faker::Localized.paragraph(sentence_count: 3) }
    let(:resource_class) { Decidim::Budgets::Budget }
    let(:total_budget) { 1234 }
    let(:attributes) do
      {
        title:,
        description:,
        total_budget:
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation {
          component(id: "#{model.id}"){
        #{"    "}
          }
          ...on BudgetsMutation {
            createBudget(input: {
              attributes: {
                title: "#{title}",
                totalBudget: "#{total_budget}",
                description: "#{description}",
              }
          })
          }
           {
            id
            title {
              translation(locale: "#{locale}")
            }
            description{
              translation(locale: "#{locale}")
            }
            totalBudget
          }
        }
      GRAPHQL
    end

    it_behaves_like "a creatable API budget"
  end
end
