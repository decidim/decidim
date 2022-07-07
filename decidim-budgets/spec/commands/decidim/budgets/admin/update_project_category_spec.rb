# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProjectCategory do
    subject { described_class.new(category_id, Array(project)) }

    let(:budget) { create(:budget) }
    let(:project) { create(:project, budget: budget) }
    let(:category) { create(:category, participatory_space: budget.component.participatory_space) }
    let(:category_id) { category.id }

    context "when everything is ok" do
      it "updates the project" do
        expect { subject.call }.to broadcast(:update_projects_category)
        expect(::Decidim::Budgets::Project.find(project.id).category).to eq(category)
      end
    end

    context "when category is blank" do
      let(:category_id) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_category)
      end
    end
  end
end
