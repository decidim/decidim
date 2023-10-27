# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProjectsBudget do
    subject { described_class.new(destin_budget_id, projects_id) }

    let!(:budgets) { create_list(:budget, 2, component: budgets_component) }
    let(:budgets_component) { create(:budgets_component) }
    let(:destin_budget) { budgets.last }
    let(:destin_budget_id) { destin_budget.id }
    let(:budget) { budgets.first }
    let(:projects_id) { budget.projects.first }

    let!(:projects) { create_list(:project, 4, budget:) }
    let(:project_ids) { projects.map(&:id) }

    context "when project_ids empty" do
      let(:project_ids) { [] }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_project_ids)
      end
    end

    context "when destination budget is not present" do
      let(:destin_budget_id) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_project_ids)
      end
    end

    context "when the destination is from another space" do
      let!(:participatory_process) { create(:participatory_process, organization: budget.organization) }
      let!(:alien_budgets_component) { create(:budgets_component, participatory_space: participatory_process) }
      let(:alien_budget) { create(:budget, component: alien_budgets_component) }

      it "broadcasts update with correct flashes" do
        successful = projects.map { |p| translated_attribute(p.title) }
        expect { subject.call }.to broadcast(:update_projects_budget, hash_including(successful:))
      end
    end
  end
end
