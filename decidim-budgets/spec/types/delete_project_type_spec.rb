# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe DeleteProjectType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { BudgetMutationType }
    let(:component) { create(:budgets_component) }
    let!(:budget) { create(:budget, component:, total_budget: 1_000) }
    let!(:project) { create(:project, budget:) }
    let!(:model) { budget }

    let(:query) do
      %( mutation { deleteProject(id: #{project.id}) { id } })
    end

    shared_examples "API deletable project" do
      it "deletes the project" do
        expect(project.deleted_at).to be_nil
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Budgets::Project, :count).by(-1)
        expect(project.reload.deleted_at).not_to be_nil
      end

      context "when missing project" do
        context "when project is missing" do
          let(:query) { %( mutation { deleteProject(id: 123456789) { id } }) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Project not found")
          end
        end

        context "when project id is not integer" do
          let(:query) { %( mutation { deleteProject(id: "aaaa") { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Project not found")
          end
        end

        context "when project belongs to another budget" do
          let!(:budget2) { create(:budget, component:, total_budget: 1_000) }
          let!(:project) { create(:project, budget: budget2) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Project not found")
          end
        end

        context "when project belongs to another budget and the budget belongs to another component" do
          let(:component2) { create(:budgets_component, organization: current_organization) }
          let!(:budget2) { create(:budget, component: component2, total_budget: 1_000) }
          let!(:project) { create(:project, budget: budget2) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Project not found")
          end
        end

        context "when project is already deleted" do
          before do
            project.destroy
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Project not found")
          end
        end
      end
    end

    it_behaves_like "admin API access checks", "API deletable project"
  end
end
