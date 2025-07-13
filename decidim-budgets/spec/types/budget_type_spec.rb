# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Budgets
    describe BudgetType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:budget, :with_projects) }

      it_behaves_like "traceable interface" do
        let(:author) { create(:user, :admin, organization: model.component.organization) }
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::EngineRouter.main_proxy(model.component).budget_url(model))
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "total_budget" do
        let(:query) { "{ total_budget }" }

        it "returns the total budget" do
          expect(response["total_budget"]).to eq(model.total_budget)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the total budget" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "projects" do
        let!(:budget2) { create(:budget, :with_projects) }
        let(:query) { "{ projects { id } }" }

        it "returns the budget projects" do
          ids = response["projects"].map { |project| project["id"] }
          expect(ids).to include(*model.projects.map(&:id).map(&:to_s))
          expect(ids).not_to include(*budget2.projects.map(&:id).map(&:to_s))
        end
      end
    end
  end
end
