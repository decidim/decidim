# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim::Budgets
  describe "Nested project mutations", type: :graphql do
    include_context "with a graphql class mutation"

    let!(:current_component) { create(:budgets_component, :published, organization: current_organization) }
    let!(:budget) { create(:budget, component: current_component, total_budget: 1_000) }
    let!(:project) { create(:project, budget:) }

    let(:response) do
      result = Decidim::Api::Schema.execute(
        query,
        context: {
          current_organization:,
          current_user:,
          current_component:,
          scopes: api_scopes,
          can_introspect: true
        }
      )

      raise_proper_error(result["errors"].first) if result["errors"]

      result["data"]
    end

    shared_examples "nested project mutation" do
      context "with an admin user" do
        let(:user_type) { :admin }

        it "resolves the project from the parent project(id:) field" do
          expect(response.dig("component", "budget", "project", field)).to include("id" => project.id.to_s)
        end
      end

      context "with a regular user" do
        let(:user_type) { :user }

        it "is not authorized" do
          expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedFieldError, /you do not have permission/)
        end
      end

      context "when the project belongs to another budget" do
        let(:user_type) { :admin }
        let!(:other_budget) { create(:budget, component: current_component, total_budget: 1_000) }
        let(:project) { create(:project, budget: other_budget) }

        it "raises an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /not found/)
        end
      end
    end

    describe "delete" do
      let(:field) { "delete" }
      let(:query) do
        <<~GRAPHQL
          mutation {
            component(id: #{current_component.id}) {
              ... on BudgetsMutation {
                budget(id: #{budget.id}) {
                  project(id: #{project.id}) {
                    delete { id }
                  }
                }
              }
            }
          }
        GRAPHQL
      end

      it_behaves_like "nested project mutation"

      context "with an admin user" do
        let(:user_type) { :admin }

        it "soft deletes the project" do
          expect(project.deleted_at).to be_nil
          expect { response }.to change(Decidim::Budgets::Project, :count).by(-1)
          expect(project.reload.deleted_at).not_to be_nil
        end
      end
    end

    describe "update" do
      let(:field) { "update" }
      let(:address) { Faker::Address.full_address }
      let(:query) do
        <<~GRAPHQL
          mutation {
            component(id: #{current_component.id}) {
              ... on BudgetsMutation {
                budget(id: #{budget.id}) {
                  project(id: #{project.id}) {
                    update(input: { attributes: { address: "#{address}" } }) { id address }
                  }
                }
              }
            }
          }
        GRAPHQL
      end

      it_behaves_like "nested project mutation"

      context "with an admin user" do
        let(:user_type) { :admin }

        it "updates the project" do
          expect(response.dig("component", "budget", "project", "update", "address")).to eq(address)
        end
      end
    end
  end
end
