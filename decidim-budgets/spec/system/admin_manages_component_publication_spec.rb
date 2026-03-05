# frozen_string_literal: true

require "spec_helper"

describe "Admin manages component publication" do
  include_context "when managing a component as an admin" do
    context "with a budget" do
      let!(:resource) { create(:budget, component:) }

      context "when cycling through publication states" do
        let!(:component) { create(:budgets_component, participatory_space:) }

        include_examples "cycling through publication states"
      end

      context "when component is unpublished, and admin publishes" do
        let!(:component) { create(:budgets_component, :unpublished, participatory_space:) }

        include_examples "add component resources to search index"
      end

      context "when component is published, and admin unpublishes" do
        let!(:component) { create(:budgets_component, :published, participatory_space:) }

        include_examples "removes component resources from search index"
      end
    end

    context "with a project" do
      let!(:budget) { create(:budget, component:) }
      let!(:resource) { create(:project, budget:) }

      context "when cycling through publication states" do
        let!(:component) { create(:budgets_component, participatory_space:) }

        include_examples "cycling through publication states"
      end

      context "when component is unpublished, and admin publishes" do
        let!(:component) { create(:budgets_component, :unpublished, participatory_space:) }

        include_examples "add component resources to search index"
      end

      context "when component is published, and admin unpublishes" do
        let!(:component) { create(:budgets_component, :published, participatory_space:) }

        include_examples "removes component resources from search index"
      end
    end
  end
end
