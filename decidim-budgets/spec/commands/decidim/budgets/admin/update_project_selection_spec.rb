# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProjectSelection do
    subject { described_class.new(selection_to_s, Array(project), current_component) }

    let(:budget) { create(:budget) }
    let(:project) { create(:project, budget:) }
    let(:current_component) { budget.component }
    let(:selection) { true }
    let(:selection_to_s) { selection.to_s }

    context "when everything is ok" do
      it "updates the project" do
        expect { subject.call }.to broadcast(:update_projects_selection)
        expect(::Decidim::Budgets::Project.find(project.id).selected?).to eq(selection)
      end
    end

    context "when selection is blank" do
      let(:selection) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_selection)
      end
    end

    context "when project is already selected for implementation" do
      let(:project) { create(:project, :selected, budget:) }
      let(:selection) { false }

      it "deselects the project" do
        expect { subject.call }.to broadcast(:update_projects_selection)
        expect(::Decidim::Budgets::Project.find(project.id).selected?).to eq(selection)
      end
    end

    context "when a project belongs to another organization" do
      let(:other_organization) { create(:organization) }
      let(:other_participatory_process) { create(:participatory_process, organization: other_organization) }
      let(:other_component) { create(:budgets_component, participatory_space: other_participatory_process) }
      let!(:other_budget) { create(:budget, component: other_component) }
      let!(:other_project) { create(:project, budget: other_budget) }

      subject { described_class.new(selection_to_s, [project.id, other_project.id], current_component) }

      it "does not update the other project" do
        expect { subject.call }.not_to(change { other_project.reload.selected? })
      end
    end
  end
end
