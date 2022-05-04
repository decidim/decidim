# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe DownloadYourDataBudgetsOrderSerializer do
    let(:resource) { create(:order) }
    let(:serialized) { subject.serialize }
    let!(:projects) { create_list(:project, 2, budget: resource.budget, budget_amount: 25_000_000) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the budget" do
        expect(serialized).to include(budget: resource.budget.title)
      end

      it "includes the component" do
        expect(serialized).to include(component: resource.budget.component.name)
      end

      it "includes the checked out at" do
        expect(serialized).to include(checked_out_at: resource.checked_out_at)
      end

      it "serializes the projects" do
        resource.projects << projects

        expect(serialized[:projects].length).to eq(2)
        expect(serialized[:projects].first).to include(id: projects.first.id)
        expect(serialized[:projects].last).to include(id: projects.last.id)
        expect(serialized[:projects].first).to include(title: projects.first.title)
        expect(serialized[:projects].last).to include(title: projects.last.title)
        expect(serialized[:projects].first).to include(description: projects.first.description)
        expect(serialized[:projects].last).to include(description: projects.last.description)
        expect(serialized[:projects].first).to include(budget_amount: projects.first.budget_amount)
        expect(serialized[:projects].last).to include(budget_amount: projects.last.budget_amount)
        expect(serialized[:projects].first).to include(scope: projects.first.scope)
        expect(serialized[:projects].last).to include(scope: projects.last.scope)
        expect(serialized[:projects].first).to include(reference: projects.first.reference)
        expect(serialized[:projects].last).to include(reference: projects.last.reference)
        expect(serialized[:projects].first).to include(created_at: projects.first.created_at)
        expect(serialized[:projects].last).to include(created_at: projects.last.created_at)
        expect(serialized[:projects].first).to include(updated_at: projects.first.updated_at)
        expect(serialized[:projects].last).to include(updated_at: projects.last.updated_at)
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: resource.created_at)
      end

      it "includes the updated at" do
        expect(serialized).to include(updated_at: resource.updated_at)
      end
    end
  end
end
