# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProjectsBudget do
    subject { described_class.new(destination_budget, project_ids, budgets_component) }

    let!(:budgets) { create_list(:budget, 2, component: budgets_component) }
    let(:budgets_component) { create(:budgets_component) }
    let(:destination_budget) { budgets.last }
    let(:budget) { budgets.first }

    let!(:projects) { create_list(:project, 4, budget:) }
    let(:project_ids) { projects.map(&:id) }

    context "when project_ids empty" do
      let(:project_ids) { [] }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_project_ids)
      end
    end

    context "when destination budget is not present" do
      let!(:destination_budget) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_project_ids)
      end
    end

    context "when the destination is from another space" do
      subject { described_class.new(alien_budget, project_ids, budgets_component) }
      let!(:participatory_process) { create(:participatory_process, organization: budget.organization) }
      let!(:alien_budgets_component) { create(:budgets_component, participatory_space: participatory_process) }
      let(:alien_budget) { create(:budget, component: alien_budgets_component) }

      it "broadcast update with errored" do
        errored = projects.map { |p| translated(p.title) }
        expect { subject.call }.to broadcast(:update_projects_budget, hash_including(selection_name: "", successful: [], errored:, failed_ids: array_including(project_ids)))
      end
    end

    context "when everything is ok" do
      it "broadcasts update with successful flashes" do
        successful = projects.map { |p| translated(p.title) }
        expect(budget.projects.count).to eq(4)
        expect(destination_budget.projects.count).to eq(0)
        expect { subject.call }.to broadcast(:update_projects_budget, hash_including(selection_name: "", successful:, errored: [], failed_ids: []))
        budget.reload
        destination_budget.reload
        expect(budget.projects.count).to eq(0)
        expect(destination_budget.projects.count).to eq(4)
      end
    end

    context "when a project belongs to another organization" do
      let(:other_organization) { create(:organization) }
      let(:other_participatory_process) { create(:participatory_process, organization: other_organization) }
      let(:other_component) { create(:budgets_component, participatory_space: other_participatory_process) }
      let(:other_budget) { create(:budget, component: other_component) }
      let!(:other_project) { create(:project, budget: other_budget) }
      let(:project_ids) { projects.map(&:id) + [other_project.id] }

      it "does not move the other project" do
        subject.call

        expect(other_project.reload.budget).to eq(other_budget)
      end
    end
  end
end
