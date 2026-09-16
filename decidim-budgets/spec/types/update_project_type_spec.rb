# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe UpdateProjectType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetMutationType }
    let(:locale) { "en" }
    let(:current_component) { create(:budgets_component, organization: current_organization) }
    let!(:budget) { create(:budget, component: current_component, total_budget: 1_000) }
    let(:participatory_process) { budget.participatory_space }
    let(:proposals_component) { create(:component, manifest_name: :proposals, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, component: proposals_component) }
    let!(:project) { create(:project, budget:) }
    let(:model) { budget }

    let(:address) { Faker::Address.full_address }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:latitude) { Faker::Address.latitude }
    let(:longitude) { Faker::Address.longitude }
    let!(:root_taxonomy) { create(:taxonomy, organization: current_organization) }
    let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: current_organization) }
    let(:taxonomy_id) { taxonomy.id }
    let(:budget_amount) { 123_4 }

    let(:variables) do
      {
        component_id: current_component.id,
        budget_id: model.id,
        input: {
          id: project.id,
          attributes: {
            title: { en: title_en },
            description: { en: description_en },
            budgetAmount: budget_amount,
            latitude:,
            address:,
            longitude:,
            proposalIds: [proposal.id],
            taxonomies: [taxonomy_id]
          }
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: UpdateProjectInput!) {
          updateProject(input: $input) {
            id
            title { translation(locale: "#{locale}") }
            description { translation(locale: "#{locale}") }
            address
            coordinates {
              latitude
              longitude
            }
            relatedProposals {
              id
            }
            taxonomies {
              id
              name { translation(locale: "#{locale}") }
            }
            budgetAmount
          }
        }
      GRAPHQL
    end

    shared_examples "API updatable project" do
      it "assigns fields" do
        project = response["updateProject"]
        expect(project["id"]).to be_present
        expect(project["title"]["translation"]).to eq(title_en)
        expect(project["description"]["translation"]).to eq(description_en)
        expect(project["budgetAmount"]).to eq(budget_amount)
        expect(project["relatedProposals"]).to eq([{ "id" => proposal.id.to_s }])
        expect(project["coordinates"]).to eq(
          { "longitude" => longitude, "latitude" => latitude }
        )
      end

      context "when having invalid arguments" do
        context "when having invalid locale" do
          let(:variables) do
            {
              component_id: current_component.id,
              budget_id: model.id,
              input: {
                id: project.id,
                attributes: {
                  title: { :en => title_en, "tlh" => "Foo bar" },
                  description: { en: description_en },
                  budgetAmount: budget_amount,
                  address:,
                  latitude:,
                  longitude:,
                  proposalIds: [proposal.id],
                  taxonomies: [taxonomy_id]
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
                id: project.id,
                attributes: {
                  title: nil,
                  description: { en: description_en },
                  budgetAmount: budget_amount,
                  address:,
                  latitude:,
                  longitude:,
                  proposalIds: [proposal.id],
                  taxonomies: [taxonomy_id]
                }
              }
            }
          end

          it "preserves the title" do
            expect(response["updateProject"]).to be_present
            expect(response["updateProject"]["title"]).to be_present
            expect(response["updateProject"]["title"]["translation"]).to eq(translated(project.title))
          end
        end

        context "when submitting budget_amount as string" do
          let(:budget_amount) { "foo" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value/)
          end
        end

        context "when submitting invalid budget_amount budget" do
          let(:budget_amount) { 0 }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /must be greater than 0/)
          end
        end

        context "when submitting taxonomy as string" do
          let(:taxonomy_id) { "foo" }

          it "raises an error" do
            expect(response["updateProject"]["taxonomies"]).to be_empty
            expect(response["updateProject"]["taxonomies"]).to eq([])
          end
        end

        context "when submitting taxonomy budget" do
          let(:taxonomy_id) { 0 }

          it "raises an error" do
            expect(response["updateProject"]["taxonomies"]).to be_empty
            expect(response["updateProject"]["taxonomies"]).to eq([])
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

    include_examples "admin API access checks", "API updatable project"
  end
end
