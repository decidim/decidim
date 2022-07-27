# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProjectSelection do
    subject { described_class.new(selection_to_s, Array(project)) }

    let(:budget) { create(:budget) }
    let(:project) { create(:project, budget:) }
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
  end
end
