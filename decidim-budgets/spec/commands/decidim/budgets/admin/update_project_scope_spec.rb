# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProjectScope do
    subject { described_class.new(scope_id, Array(project)) }

    let(:budget) { create(:budget) }
    let(:project) { create(:project, budget: budget) }
    let(:scope) { create(:scope, organization: budget.component.organization) }
    let(:scope_id) { scope.id }

    context "when everything is ok" do
      it "updates the project" do
        expect { subject.call }.to broadcast(:update_projects_scope)
        expect(::Decidim::Budgets::Project.find(project.id).scope).to eq(scope)
      end
    end

    context "when scope is blank" do
      let(:scope_id) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid_scope)
      end
    end
  end
end
