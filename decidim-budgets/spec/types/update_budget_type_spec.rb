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
            totalBudget
          }
        }
      GRAPHQL
    end

    shared_examples "API updatable budget" do
      context "when updating a budget" do
        it "updates fields" do
          updated_budget = response["updateBudget"]
          expect(updated_budget["id"].to_i).to eq(model.id)
          expect(updated_budget["title"]["translation"]).to eq(title_en)
          expect(updated_budget["description"]["translation"]).to eq(description_en)
          expect(updated_budget["totalBudget"]).to eq(total_budget)
        end

        context "when performing a partial update" do
          let(:variables) do
            {
              component_id: current_component.id,
              budget_id:,
              input: {
                attributes: {
                  title: { "es" => "El título en español" },
                  description: { en: description_en },
                  totalBudget: total_budget
                }
              }
            }
          end

          it "updates only specified fields" do
            updated_budget = response["updateBudget"]
            expect(updated_budget["id"].to_i).to eq(model.id)
            expect(updated_budget["title"]["translation"]).to eq(translated(model.title))
          end
        end
      end

      context "when having invalid arguments" do
        context "when having invalid locale" do
          let(:variables) do
            {
              component_id: current_component.id,
              budget_id: model.id,
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

        context "when having null title" do
          let(:variables) do
            {
              component_id: current_component.id,
              budget_id: model.id,
              input: {
                attributes: {
                  title: nil,
                  description: { en: description_en },
                  totalBudget: total_budget
                }
              }
            }
          end

          it "preserves the title" do
            expect(response["updateBudget"]).to be_present
            expect(response["updateBudget"]["title"]).to be_present
            expect(response["updateBudget"]["title"]["translation"]).to eq(translated(model.title))
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
      end
    end

    include_examples "admin API access checks", "API updatable budget"
  end
end
