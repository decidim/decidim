# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe CreateBudgetType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetsMutationType }
    let(:locale) { "en" }
    let(:model) { create(:budgets_component) }
    let(:current_component) { model }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:resource_class) { Decidim::Budgets::Budget }
    let(:total_budget) { 1234 }
    let(:variables) do
      {
        input: {
          attributes: {
            title: { en: title_en },
            totalBudget: total_budget,
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
            totalBudget
          }
        }
      GRAPHQL
    end

    shared_examples "API creatable budget" do
      it "creates a new budget" do
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Budgets::Budget, :count).by(1)
      end

      it "assigns fields" do
        budget = response["createBudget"]
        expect(budget["id"]).to be_present
        expect(budget["title"]["translation"]).to eq(title_en)
        expect(budget["description"]["translation"]).to eq(description_en)
        expect(budget["totalBudget"]).to eq(total_budget)
      end

      context "when having invalid arguments" do
        context "when having invalid locale" do
          let(:variables) do
            {
              component_id: current_component.id,
              input: {
                attributes: {
                  title: { "en" => title_en, "tlh" => "Foo bar" },
                  description: { en: description_en },
                  totalBudget: total_budget
                }
              }
            }
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "when submitting total budget as string" do
          let(:total_budget) { "foo" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value/)
          end
        end

        context "when submitting invalid total budget" do
          let(:total_budget) { 0 }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /must be greater than 0/)
          end
        end

        context "when submitting invalid title for budget" do
          let(:title_en) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when having null title" do
          let(:variables) do
            {
              component_id: current_component.id,
              input: {
                attributes: {
                  title: nil,
                  description: { en: description_en },
                  totalBudget: total_budget
                }
              }
            }
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end
      end
    end

    include_examples "admin API access checks", "API creatable budget"
  end
end
