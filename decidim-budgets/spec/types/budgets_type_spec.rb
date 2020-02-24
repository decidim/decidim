# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Budgets
    describe BudgetsType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { create(:budget_component) }

      it_behaves_like "a component query type"

      describe "projects" do
        let!(:component_projects) { create_list(:project, 2, component: model) }
        let!(:other_projects) { create_list(:project, 2) }

        let(:query) { "{ projects { edges { node { id } } } }" }

        it "returns the projects" do
          ids = response["projects"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_projects.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_projects.map(&:id).map(&:to_s))
        end
      end

      describe "project" do
        let(:query) { "query Project($id: ID!){ project(id: $id) { id } }" }
        let(:variables) { { id: project.id.to_s } }

        context "when the project belongs to the component" do
          let!(:project) { create(:project, component: model) }

          it "finds the project" do
            expect(response["project"]["id"]).to eq(project.id.to_s)
          end
        end

        context "when the project does not belong to the component" do
          let!(:project) { create(:project, component: create(:budget_component)) }

          it "returns null" do
            expect(response["project"]).to be_nil
          end
        end
      end
    end
  end
end
