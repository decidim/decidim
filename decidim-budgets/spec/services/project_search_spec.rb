# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectSearch do
    subject { described_class.new(params).results }

    let(:component) { create :component, manifest_name: "budgets" }
    let(:default_params) { { budget: budget, component: component } }
    let(:params) { default_params }
    let!(:budget) { create :budget, component: component }
    let(:resource_params) { { budget: budget } }

    it_behaves_like "a resource search", :project
    it_behaves_like "a resource search with scopes", :project
    it_behaves_like "a resource search with categories", :project

    describe "base query" do
      context "when no budget is passed" do
        let(:default_params) { { budget: nil, component: component } }

        it "raises an error" do
          expect { subject }.to raise_error(StandardError, "Missing budget")
        end
      end
    end

    describe "filters" do
      context "when `global` is being sent" do
        let!(:resource_without_scope) { create(:project, budget: budget, scope: nil) }
        let(:params) { default_params.merge(scope_id: ["global"]) }

        it "returns resources without a scope" do
          expect(subject).to eq [resource_without_scope]
        end
      end

      context "when votes are finished" do
        let(:component) { create(:budgets_component, :with_voting_finished) }
        let!(:resource_selected) { create(:project, :selected, budget: budget) }
        let!(:resource_not_selected) { create(:project, budget: budget) }

        context "and the user doesn't filter by status" do
          it { expect(subject).to match_array([resource_selected, resource_not_selected]) }
        end

        context "and the user filters selected projects" do
          let(:params) { default_params.merge(status: ["selected"]) }

          it { expect(subject).to eq [resource_selected] }
        end

        context "and the user filters not selected projects" do
          let(:params) { default_params.merge(status: ["not_selected"]) }

          it { expect(subject).to eq [resource_not_selected] }
        end
      end
    end
  end
end
