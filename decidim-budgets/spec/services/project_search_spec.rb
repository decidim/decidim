# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectSearch do
    subject { described_class.new(params) }

    let(:current_component) { create :budgets_component }
    let(:scope1) { create :scope, organization: current_component.organization }
    let(:scope2) { create :scope, organization: current_component.organization }
    let(:parent_category) { create :category, participatory_space: current_component.participatory_space }
    let(:subcategory) { create :subcategory, parent: parent_category }
    let(:budget) { create :budget, component: current_component }
    let!(:project1) do
      create(
        :project,
        budget: budget,
        category: parent_category,
        scope: scope1
      )
    end
    let!(:project2) do
      create(
        :project,
        budget: budget,
        category: subcategory,
        scope: scope2
      )
    end
    let(:external_project) { create :project }
    let(:budget_id) { budget.id }
    let(:organization_id) { current_component.organization.id }
    let(:default_params) { { budget: budget, component: current_component } }
    let(:params) { default_params }

    describe "base query" do
      context "when no budget is passed" do
        let(:default_params) { { budget: nil } }

        it "raises an error" do
          expect { subject.results }.to raise_error(StandardError, "Missing budget")
        end
      end
    end

    describe "filters" do
      context "with budget_id" do
        it "only returns projects from the given budget" do
          external_project = create(:project)

          expect(subject.results).not_to include(external_project)
        end
      end

      context "with scope_id" do
        context "when a single id is being sent" do
          let(:params) { default_params.merge(scope_id: scope1.id) }

          it "filters projects by scope" do
            expect(subject.results).to eq [project1]
          end
        end

        context "when multiple ids are sent" do
          let(:params) { default_params.merge(scope_id: [scope2.id, scope1.id]) }

          it "filters projects by scope" do
            expect(subject.results).to match_array [project1, project2]
          end
        end

        context "when `global` is being sent" do
          let!(:resource_without_scope) { create(:project, budget: budget, scope: nil) }
          let(:params) { default_params.merge(scope_id: ["global"]) }

          it "returns resources without a scope" do
            expect(subject.results).to eq [resource_without_scope]
          end
        end
      end

      context "with category_id" do
        context "when the given category has no subcategories" do
          let(:params) { default_params.merge(category_id: subcategory.id) }

          it "returns only projects from the given category" do
            expect(subject.results).to eq [project2]
          end
        end

        context "when the given category has some subcategories" do
          let(:params) { default_params.merge(category_id: parent_category.id) }

          it "returns projects from this category and its children's" do
            expect(subject.results).to match_array [project2, project1]
          end
        end

        context "when the category does not belong to the current component" do
          let(:external_category) { create :category }
          let(:params) { default_params.merge(category_id: external_category.id) }

          it "returns an empty array" do
            expect(subject.results).to eq []
          end
        end
      end
    end
  end
end
