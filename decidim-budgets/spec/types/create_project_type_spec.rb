# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe CreateProjectType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetMutationType }
    let(:locale) { "en" }
    let(:current_component) { create(:budgets_component, organization: current_organization) }

    let!(:model) { create(:budget, component: current_component, total_budget: 1_000) }
    let(:participatory_process) { model.participatory_space }
    let(:proposals_component) { create(:component, manifest_name: :proposals, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, component: proposals_component) }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:latitude) { Faker::Address.latitude }
    let(:longitude) { Faker::Address.longitude }
    let!(:root_taxonomy) { create(:taxonomy, organization: current_organization) }
    let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: current_organization) }
    let(:taxonomy_id) { taxonomy.id }
    let(:budget_amount) { 123_4 }
    let(:address) { Faker::Address.full_address }
    let(:variables) do
      {
        component_id: current_component.id,
        budget_id: model.id,
        input: {
          attributes: {
            address:,
            title: { en: title_en },
            description: { en: description_en },
            budgetAmount: budget_amount,
            latitude:,
            longitude:,
            proposalIds: [proposal.id],
            taxonomies: [taxonomy_id]
          }
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: CreateProjectInput!){
          createProject(input: $input){
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

    shared_examples "API creatable project" do
      it "creates a new project" do
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Budgets::Project, :count).by(1)
      end

      it "assigns fields" do
        project = response["createProject"]
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

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when submitting budget_amount as string" do
          let(:budget_amount) { "foo" }

          it "raises an error" do
            expect { response }.to raise_error(GraphQL::ExecutionError, /Could not coerce value/)
          end
        end

        context "when submitting invalid budget_amount in project" do
          let(:budget_amount) { 0 }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /must be greater than 0/)
          end
        end

        context "when submitting taxonomy as string" do
          let(:taxonomy_id) { "foo" }

          it "raises an error" do
            expect(response["createProject"]["taxonomies"]).to be_empty
            expect(response["createProject"]["taxonomies"]).to eq([])
          end
        end

        context "when submitting taxonomy in project" do
          let(:taxonomy_id) { 0 }

          it "raises an error" do
            expect(response["createProject"]["taxonomies"]).to be_empty
            expect(response["createProject"]["taxonomies"]).to eq([])
          end
        end

        context "when submitting invalid title for project" do
          let(:title_en) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end
      end
    end

    include_examples "admin API access checks", "API creatable project"
  end
end
