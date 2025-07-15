# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

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

    context "with admin user" do
      it_behaves_like "API deletable project" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        deleted_project = response["deleteProject"]
        expect(deleted_project).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API deletable project" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
